import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/liability_provider.dart';
import '../ui_constants.dart';
import '../widgets/bank_selector.dart';
import '../widgets/credit_institution_selector.dart';
import '../database/database.dart';
import 'liability/liability_theme.dart';

/// 统一计算首次扣款日 = "下一个还没到的还款日"
/// - 还款日 >= 今天 → 落在本月该日
/// - 还款日 < 今天   → 顺延到下个月该日（本月不再有待还）
/// 短月兜底：还款日 31 号遇 2 月等不足天数的月份，钳制到当月最后一天。
DateTime firstPaymentFromRepayDay(int repayDay) {
  final now = DateTime.now();
  int year = now.year;
  int month = now.month;
  if (now.day > repayDay) {
    month += 1;
    if (month > 12) {
      month = 1;
      year += 1;
    }
  }
  final daysInMonth = DateTime(year, month + 1, 0).day;
  return DateTime(year, month, repayDay > daysInMonth ? daysInMonth : repayDay);
}

/// 新增负债页面
/// 完整复刻 record_page.dart 内嵌负债 Tab 的逻辑（含消费分期总金额自动计算、other 月付信贷等 6 种类型）
class AddLiabilityPage extends StatefulWidget {
  const AddLiabilityPage({super.key});

  @override
  State<AddLiabilityPage> createState() => _AddLiabilityPageState();
}

class _AddLiabilityPageState extends State<AddLiabilityPage> {
  // 表单输入控制器
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();

  // 选中类型
  String _selectedType = 'credit_card';

  // 信用卡 / 房贷 / 车贷 共用
  BankItem? _selectedBank;
  String _repayDay = '';

  // 消费分期 / 月付信贷（other）
  LocalCreditInstitutionsData? _selectedInstitution;
  String _installmentRepayDay = '';
  String _personalRepayDay = '';

  // 信用卡/月付信贷专用：每月还款日（dueDate 已废弃，用 repayDate 字段存储）
  // 初始值 = 1 号的"下一个还没到的 1 号"，用户选定还款日后由 _syncRepayDateDay 刷新
  DateTime _repayDate = firstPaymentFromRepayDay(1);

  // 日期
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  // 房贷/车贷：还款日（每月几号）
  String _loanRepayDay = '';
  // 房贷/车贷：到期日（年月）
  DateTime _loanDueDate = DateTime(DateTime.now().year + 10, DateTime.now().month, 1);

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    _remarkController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  // ============================================================
  // 计算 / 校验
  // ============================================================
  LiabilityTypeConfig get _currentConfig {
    return liabilityTypeConfigs.firstWhere(
      (c) => c.value == _selectedType,
      orElse: () => liabilityTypeConfigs.first,
    );
  }

  bool get _canSubmit {
    final amount = (double.tryParse(_amountController.text) ?? 0) > 0;
    if (_selectedType == 'mortgage' || _selectedType == 'car_loan') {
      return amount && _selectedBank != null;
    }
    if (_selectedType == 'credit_card') {
      return amount && _selectedBank != null && _repayDay.isNotEmpty;
    }
    if (_selectedType == 'installment') {
      return amount && _selectedInstitution != null && _installmentRepayDay.isNotEmpty;
    }
    if (_selectedType == 'other') {
      return amount && _personalRepayDay.isNotEmpty && _selectedInstitution != null;
    }
    if (_selectedType == 'personal') {
      return _nameController.text.trim().isNotEmpty && amount;
    }
    return amount;
  }

  /// 消费分期：根据到期日和还款日计算总期数
  /// 消费分期：首次扣款日（还款日已过则顺延到下个月）
  DateTime? get _installmentFirstPaymentDate {
    if (_installmentRepayDay.isEmpty) return null;
    final repayDay = int.tryParse(_installmentRepayDay) ?? 1;
    return firstPaymentFromRepayDay(repayDay);
  }

  int get _installmentMonths {
    if (_selectedType != 'installment' || _installmentRepayDay.isEmpty) return 0;
    final firstDate = _installmentFirstPaymentDate;
    if (firstDate == null) return 0;
    final due = _dueDate;
    int months = (due.year - firstDate.year) * 12 + (due.month - firstDate.month);
    return (months + 1).clamp(1, 999);
  }

  /// 消费分期：总金额 = 月供 × 期数
  double get _installmentTotalAmount {
    final monthly = double.tryParse(_amountController.text) ?? 0;
    return monthly * _installmentMonths;
  }

  /// 房贷/车贷：总期数（月），与 _installmentMonths 同结构
  int get _loanMonths {
    if (_selectedType != 'mortgage' && _selectedType != 'car_loan') return 0;
    if (_loanRepayDay.isEmpty) return 0;
    final start = _loanFirstPaymentDateFromRepayDay(_loanRepayDay);
    final due = _loanDueDate;
    int months = (due.year - start.year) * 12 + (due.month - start.month);
    return (months + 1).clamp(1, 999);
  }

  /// 房贷/车贷：总金额 = 月供 × 期数
  double get _loanTotalAmount {
    final monthly = double.tryParse(_amountController.text) ?? 0;
    return monthly * _loanMonths;
  }

  // ============================================================
  // 提交
  // ============================================================
  /// 提交保存负债
  /// - [closeAfter]=true：保存成功后关闭页面（"保存负债"按钮）
  /// - [closeAfter]=false：保存成功后清空表单、不关闭页面（"在记一笔"按钮）
  Future<void> _submit({bool closeAfter = true}) async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_selectedType == 'installment' ? '请输入正确的月供金额' : '请输入正确的负债金额'),
          backgroundColor: AppColors.expense,
        ),
      );
      return;
    }
    if ((_selectedType == 'credit_card' || _selectedType == 'mortgage' || _selectedType == 'car_loan') &&
        _selectedBank == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('请选择机构'), backgroundColor: AppColors.expense),
      );
      return;
    }
    if (_selectedType == 'credit_card' && _repayDay.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('请选择还款日'), backgroundColor: AppColors.expense),
      );
      return;
    }
    if ((_selectedType == 'mortgage' || _selectedType == 'car_loan') && _loanRepayDay.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('请选择还款日'), backgroundColor: AppColors.expense),
      );
      return;
    }
    if (_selectedType == 'installment' && _selectedInstitution == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('请选择信贷机构'), backgroundColor: AppColors.expense),
      );
      return;
    }
    if (_selectedType == 'personal' && _nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('请输入负债名称'), backgroundColor: AppColors.expense),
      );
      return;
    }
    if (_selectedType == 'other' && _personalRepayDay.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('请选择还款日'), backgroundColor: AppColors.expense),
      );
      return;
    }
    if (_selectedType == 'other' && _selectedInstitution == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('请选择信贷机构'), backgroundColor: AppColors.expense),
      );
      return;
    }

    // 月付类（消费分期/房贷/车贷）：自动计算总金额 = 月供 × 期数
    // 一次性负债（信用卡/月付信贷/私人借款）：直接用输入的本金
    final double totalAmount;
    if (_selectedType == 'installment') {
      totalAmount = _installmentTotalAmount;
    } else if (_selectedType == 'mortgage' || _selectedType == 'car_loan') {
      totalAmount = _loanTotalAmount;
    } else {
      totalAmount = amount;
    }

    // 显示加载
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 负债名称：未填时用机构名兜底，再无则用类型标签
      final String liabilityName;
      if (_nameController.text.trim().isNotEmpty) {
        liabilityName = _nameController.text.trim();
      } else if (_selectedBank != null) {
        liabilityName = _selectedBank!.name;
      } else if (_selectedInstitution != null) {
        liabilityName = _selectedInstitution!.name;
      } else {
        liabilityName = liabilityTypeConfigs.firstWhere((t) => t.value == _selectedType).label;
      }

      // 房贷/车贷：到期日作为最终 dueDate
      final dueDate = (_selectedType == 'mortgage' || _selectedType == 'car_loan')
          ? _loanDueDate
          : _dueDate;
      // 房贷/车贷首次扣款日（按还款日计算最近一次 ≤ 今天的日期）
      final firstPaymentDate = (_selectedType == 'mortgage' || _selectedType == 'car_loan')
          ? _loanFirstPaymentDateFromRepayDay(_loanRepayDay)
          : (_selectedType == 'installment' ? _installmentFirstPaymentDate : null);
      // 房贷/车贷末期日
      final lastPaymentDate = (_selectedType == 'mortgage' || _selectedType == 'car_loan')
          ? _loanDueDate
          : (_selectedType == 'installment' ? _dueDate : null);

      // 信用卡/月付信贷：repayDate 才是真正的每月还款日（dueDate 已废弃）
      final repayDate = (_selectedType == 'credit_card' || _selectedType == 'other')
          ? _repayDate
          : null;

      await context.read<LiabilityProvider>().addLiability(
            name: liabilityName,
            type: _selectedType,
            accountId: 'default',
            totalAmount: totalAmount,
            dueDate: dueDate,
            remark: _remarkController.text.isEmpty ? null : _remarkController.text,
            institution: (_selectedType == 'credit_card' ||
                    _selectedType == 'mortgage' ||
                    _selectedType == 'car_loan')
                ? _selectedBank?.name
                : (_selectedType == 'installment' || _selectedType == 'other')
                    ? _selectedInstitution?.name
                    : null,
            firstPaymentDate: firstPaymentDate,
            lastPaymentDate: lastPaymentDate,
            repayDate: repayDate,
          );

      if (mounted) Navigator.pop(context); // 关闭 loading

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(closeAfter ? '负债添加成功' : '已保存，继续记下一笔'),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 1),
          ),
        );
        if (closeAfter) {
          Navigator.pop(context, true); // 返回 true 表示添加成功
        } else {
          _resetForm();
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // 关闭 loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e'), backgroundColor: AppColors.expense),
        );
      }
    }
  }

  /// 清空表单到初始状态，保留 _selectedType（连续添加同类型负债更顺手）。
  void _resetForm() {
    setState(() {
      _amountController.clear();
      _nameController.clear();
      _remarkController.clear();
      _selectedBank = null;
      _selectedInstitution = null;
      _repayDay = '';
      _installmentRepayDay = '';
      _personalRepayDay = '';
      _loanRepayDay = '';
      _repayDate = firstPaymentFromRepayDay(1);
      _dueDate = DateTime.now().add(const Duration(days: 30));
      _loanDueDate = DateTime(DateTime.now().year + 10, DateTime.now().month, 1);
    });
  }

  // ============================================================
  // Build
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final config = _currentConfig;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.background, shape: BoxShape.circle),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          '新增负债',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _buildTypeSection(config),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _amountFocusNode.unfocus(),
              child: _buildFormCard(config),
            ),
            const SizedBox(height: 24),
            _buildSaveButton(config),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 类型选择区
  // ============================================================
  Widget _buildTypeSection(LiabilityTypeConfig config) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: config.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.category, color: config.color, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                '选择负债类型',
                style: TextStyle(fontSize: 15, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.95,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: liabilityTypeConfigs.length,
            itemBuilder: (context, index) {
              final type = liabilityTypeConfigs[index];
              return _buildTypeCard(type, _selectedType == type.value, config.color);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTypeCard(LiabilityTypeConfig type, bool isSelected, Color currentColor) {
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type.value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? type.color.withValues(alpha: 0.12) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? type.color : AppColors.divider, width: isSelected ? 2 : 1),
          boxShadow: isSelected
              ? [BoxShadow(color: type.color.withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 4))]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(colors: type.gradient, begin: Alignment.topLeft, end: Alignment.bottomRight)
                    : null,
                color: isSelected ? null : type.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(type.icon, color: isSelected ? Colors.white : type.color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              type.label,
              style: TextStyle(
                fontSize: 13,
                color: isSelected ? type.color : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 表单区（按类型动态展示字段）
  // ============================================================
  Widget _buildFormCard(LiabilityTypeConfig config) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          _buildFormRow(label: '负债名称', child: _nameField(config)),
          _buildFormRow(
            label: (_selectedType == 'installment' ||
                    _selectedType == 'mortgage' ||
                    _selectedType == 'car_loan')
                ? '月供金额'
                : '负债金额',
            isRequired: true,
            child: _amountField(),
          ),
          // 信用卡 / 房贷 / 车贷：选择机构
          if (_selectedType == 'credit_card' ||
              _selectedType == 'mortgage' ||
              _selectedType == 'car_loan')
            _buildFormRow(
              label: '银行机构',
              isRequired: true,
              child: _buildBankSelector(config),
            ),
          // 信用卡：还款日
          if (_selectedType == 'credit_card')
            _buildFormRow(label: '还款日', isRequired: true, child: _buildRepayDayPicker(config)),
          // 房贷/车贷：还款日 + 到期日
          if (_selectedType == 'mortgage' || _selectedType == 'car_loan') ...[
            _buildFormRow(label: '还款日', isRequired: true, child: _buildLoanRepayDayPicker(config)),
            _buildFormRow(label: '到期日', isRequired: true, child: _buildLoanDueDatePicker(config)),
          ],
          // 月付信贷：还款日 + 信贷机构
          if (_selectedType == 'other') ...[
            _buildFormRow(label: '还款日', isRequired: true, child: _buildPersonalRepayDayPicker(config)),
            _buildFormRow(label: '信贷机构', isRequired: true, child: _buildInstitutionSelector(config)),
          ],
          // 消费分期：信贷机构 + 还款日 + 到期日 + 总金额 + 期数提示
          if (_selectedType == 'installment') ...[
            _buildFormRow(label: '信贷机构', isRequired: true, child: _buildInstitutionSelector(config)),
            _buildFormRow(label: '还款日', isRequired: true, child: _buildInstallmentRepayDayPicker(config)),
            _buildFormRow(label: '到期日', isRequired: true, child: _buildInstallmentDueDatePicker(config)),
            _buildFormRow(
              label: '总金额',
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '¥ ${_installmentTotalAmount.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.info_outline, size: 12, color: config.color.withValues(alpha: 0.6)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _installmentRepayDay.isEmpty
                          ? '请选择还款日'
                          : '共 $_installmentMonths 期（首期 ${DateFormat('M月d日').format(_installmentFirstPaymentDate ?? DateTime.now())}）',
                      style: TextStyle(fontSize: 11, color: config.color.withValues(alpha: 0.7)),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
          ],
          _buildFormRow(label: '备注', child: _remarkField()),
        ],
      ),
    );
  }

  Widget _nameField(LiabilityTypeConfig config) {
    return TextField(
      controller: _nameController,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        hintText: _selectedType == 'personal' ? '请输入名称' : '默认使用类型名称',
        hintStyle: TextStyle(color: AppColors.textTertiary),
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _amountField() {
    return TextField(
      controller: _amountController,
      focusNode: _amountFocusNode,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        hintText: '0.00',
        hintStyle: TextStyle(color: AppColors.textTertiary),
        prefixText: '¥ ',
        prefixStyle: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _remarkField() {
    return TextField(
      controller: _remarkController,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        hintText: '选填',
        hintStyle: TextStyle(color: AppColors.textTertiary),
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
    );
  }

  Widget _buildFormRow({required String label, required Widget child, bool isRequired = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.divider.withValues(alpha: 0.5), width: 0.5)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Row(
              children: [
                if (isRequired) Text('*', style: TextStyle(color: AppColors.expense, fontSize: 14)),
                Text(label, style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  // ============================================================
  // 选择器
  // ============================================================
  Widget _buildBankSelector(LiabilityTypeConfig config) {
    return InkWell(
      onTap: () => _showBankPicker(config),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_selectedBank != null) ...[
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _parseHexColor(_selectedBank!.color).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(child: Text(_selectedBank!.icon, style: const TextStyle(fontSize: 14))),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              _selectedBank?.name ?? '请选择',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: _selectedBank != null ? AppColors.textPrimary : AppColors.textTertiary,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: config.color, size: 20),
        ],
      ),
    );
  }

  Future<void> _showBankPicker(LiabilityTypeConfig config) async {
    final selected = await BankSelector.show(context, currentBank: _selectedBank);
    if (selected != null) {
      setState(() => _selectedBank = selected);
    }
  }

  Widget _buildRepayDayPicker(LiabilityTypeConfig config) {
    return InkWell(
      onTap: () => _showRepayDayPicker(
        config,
        _repayDay,
        (v) {
          _repayDay = v;
          // 写入 _repayDate.day（信用卡 dueDate 已废弃）
          _syncRepayDateDay(v);
        },
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            _repayDay.isEmpty ? '请选择' : _repayDay,
            style: TextStyle(
              fontSize: 14,
              color: _repayDay.isEmpty ? AppColors.textTertiary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.calendar_today, color: config.color, size: 18),
        ],
      ),
    );
  }

  Widget _buildPersonalRepayDayPicker(LiabilityTypeConfig config) {
    return InkWell(
      onTap: () => _showRepayDayPicker(
        config,
        _personalRepayDay,
        (v) {
          _personalRepayDay = v;
          // 写入 _repayDate.day（月付信贷 dueDate 已废弃）
          _syncRepayDateDay(v);
        },
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            _personalRepayDay.isEmpty ? '请选择' : _personalRepayDay,
            style: TextStyle(
              fontSize: 14,
              color: _personalRepayDay.isEmpty ? AppColors.textTertiary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.calendar_today, color: config.color, size: 18),
        ],
      ),
    );
  }

  Widget _buildInstallmentRepayDayPicker(LiabilityTypeConfig config) {
    return InkWell(
      onTap: () => _showInstallmentRepayDayPicker(config),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            _installmentRepayDay.isEmpty ? '请选择' : '每月$_installmentRepayDay日',
            style: TextStyle(
              fontSize: 14,
              color: _installmentRepayDay.isEmpty ? AppColors.textTertiary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.calendar_today, color: config.color, size: 18),
        ],
      ),
    );
  }

  void _showRepayDayPicker(LiabilityTypeConfig config, String current, ValueChanged<String> onPicked) {
    // 限定 1-28 号，避开 29/30/31 在小月（2 月等）无对应日期的边界问题
    const daysInCurrentMonth = 28;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: config.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.calendar_today, color: config.color, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '选择还款日',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '可选 1-28 日，每月固定日期扣款',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(daysInCurrentMonth, (index) {
                        final day = index + 1;
                        final value = '$day日';
                        final isSelected = current == value;
                        return GestureDetector(
                          onTap: () {
                            setState(() => onPicked(value));
                            Navigator.pop(ctx);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 60,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isSelected ? config.color : AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: config.color.withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                value,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : AppColors.textPrimary,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  }

  void _showInstallmentRepayDayPicker(LiabilityTypeConfig config) {
    // 消费分期的还款日按日历日选，每月扣款时若当月不足则归到月末
    // 限定 1-28 号，避开 29/30/31 在小月（2 月等）无对应日期的边界问题
    const daysInCurrentMonth = 28;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: config.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.calendar_today, color: config.color, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '选择还款日',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '可选 1-28 日，每月固定日期扣款',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(daysInCurrentMonth, (index) {
                        final day = index + 1;
                        final value = '$day';
                        final isSelected = _installmentRepayDay == value;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _installmentRepayDay = value;
                              // 同步到期日的 day（年-月选择器背后仍按还款日构造完整日期）
                              _syncInstallmentDueDateDay(value);
                            });
                            Navigator.pop(ctx);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 60,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isSelected ? config.color : AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: config.color.withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                '$value日',
                                style: TextStyle(
                                  color: isSelected ? Colors.white : AppColors.textPrimary,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  }

  Widget _buildInstitutionSelector(LiabilityTypeConfig config) {
    return InkWell(
      onTap: () => _showCreditInstitutionSelector(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_selectedInstitution != null) ...[
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _parseHexColor(_selectedInstitution!.color).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Icon(
                  _parseIcon(_selectedInstitution!.icon),
                  color: _parseHexColor(_selectedInstitution!.color),
                  size: 14,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              _selectedInstitution?.name ?? '请选择',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: _selectedInstitution != null ? AppColors.textPrimary : AppColors.textTertiary,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: config.color, size: 20),
        ],
      ),
    );
  }

  Future<void> _showCreditInstitutionSelector() async {
    final selected = await CreditInstitutionSelector.show(context, currentInstitution: _selectedInstitution);
    if (selected != null) {
      setState(() => _selectedInstitution = selected);
    }
  }

  /// 消费分期：到期日（仅选年月，day 自动同步还款日，保证 _extractRepayDay(dueDate.day) 仍能拿到正确值）
  Widget _buildInstallmentDueDatePicker(LiabilityTypeConfig config) {
    return InkWell(
      onTap: () => _showDatePickerSheet(
        title: '选择到期日',
        initial: _dueDate,
        yearMonthOnly: true,
        onConfirm: (dt) {
          final day = int.tryParse(_installmentRepayDay) ?? dt.day;
          final daysInMonth = DateTime(dt.year, dt.month + 1, 0).day;
          final actualDay = day > daysInMonth ? daysInMonth : day;
          setState(() => _dueDate = DateTime(dt.year, dt.month, actualDay));
        },
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(DateFormat('yyyy年MM月').format(_dueDate),
              style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
          const SizedBox(width: 4),
          Icon(Icons.calendar_today, color: config.color, size: 18),
        ],
      ),
    );
  }

  /// 消费分期：还款日变更时同步到期日的 day
  void _syncInstallmentDueDateDay(String repayDayValue) {
    final day = int.tryParse(repayDayValue.replaceAll(RegExp(r'[^0-9]'), '')) ?? _dueDate.day;
    final daysInMonth = DateTime(_dueDate.year, _dueDate.month + 1, 0).day;
    final actualDay = day > daysInMonth ? daysInMonth : day;
    _dueDate = DateTime(_dueDate.year, _dueDate.month, actualDay);
  }

  /// 信用卡/月付信贷：还款日变更时同步 _repayDate（dueDate 已废弃）
  /// 还款日已过则顺延到下个月，本月不计入待还
  void _syncRepayDateDay(String repayDayValue) {
    final day = int.tryParse(repayDayValue.replaceAll(RegExp(r'[^0-9]'), '')) ?? _repayDate.day;
    _repayDate = firstPaymentFromRepayDay(day);
  }

  /// 房贷/车贷：还款日（每月几号），仅选日
  Widget _buildLoanRepayDayPicker(LiabilityTypeConfig config) {
    return InkWell(
      onTap: () => _showRepayDayPicker(
        config,
        _loanRepayDay,
        (v) => _loanRepayDay = v,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            _loanRepayDay.isEmpty ? '请选择' : '每月$_loanRepayDay',
            style: TextStyle(
              fontSize: 14,
              color: _loanRepayDay.isEmpty ? AppColors.textTertiary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.calendar_today, color: config.color, size: 18),
        ],
      ),
    );
  }

  /// 根据"每月几号"计算首次扣款日：还款日已过则顺延到下个月
  DateTime _loanFirstPaymentDateFromRepayDay(String repayDayValue) {
    final repayDay = int.tryParse(repayDayValue.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
    return firstPaymentFromRepayDay(repayDay);
  }

  /// 房贷/车贷：到期日（仅年月）
  Widget _buildLoanDueDatePicker(LiabilityTypeConfig config) {
    return InkWell(
      onTap: () => _showDatePickerSheet(
        title: '选择到期日',
        initial: _loanDueDate,
        yearMonthOnly: true,
        onConfirm: (dt) => setState(() => _loanDueDate = dt),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(DateFormat('yyyy年MM月').format(_loanDueDate),
              style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
          const SizedBox(width: 4),
          Icon(Icons.calendar_today, color: config.color, size: 18),
        ],
      ),
    );
  }

  Future<void> _showDatePickerSheet({
    required String title,
    required DateTime initial,
    required ValueChanged<DateTime> onConfirm,
    bool yearMonthOnly = false, // true: 只选年月（用于到期日）
  }) async {
    final now = DateTime.now();
    final startYear = now.year;
    final years = List.generate(50, (i) => startYear + i);
    final months = List.generate(12, (i) => i + 1);
    final days = List.generate(31, (i) => i + 1);

    int selectedYear = initial.year;
    int selectedMonth = initial.month;
    int selectedDay = yearMonthOnly ? 1 : initial.day;

    int daysInMonth(int year, int month) {
      if (month == 2) {
        return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0) ? 29 : 28;
      }
      if ([4, 6, 9, 11].contains(month)) return 30;
      return 31;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final cfg = _currentConfig;
          return Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, -4)),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(20)),
                          child: IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () => Navigator.pop(ctx),
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: AppColors.divider),
                  SizedBox(
                    height: 200,
                    child: Row(
                      children: [
                        const SizedBox(width: 20),
                        _buildDateWheel(
                          items: years,
                          initialIndex: selectedYear - startYear,
                          suffix: '年',
                          onChanged: (idx) {
                            selectedYear = years[idx];
                            if (selectedDay > daysInMonth(selectedYear, selectedMonth)) {
                              selectedDay = daysInMonth(selectedYear, selectedMonth);
                            }
                            setSheetState(() {});
                          },
                        ),
                        _buildDateWheel(
                          items: months,
                          initialIndex: selectedMonth - 1,
                          suffix: '月',
                          padZero: true,
                          onChanged: (idx) {
                            selectedMonth = months[idx];
                            if (selectedDay > daysInMonth(selectedYear, selectedMonth)) {
                              selectedDay = daysInMonth(selectedYear, selectedMonth);
                            }
                            setSheetState(() {});
                          },
                        ),
                        if (!yearMonthOnly)
                          _buildDateWheel(
                            items: days,
                            initialIndex: selectedDay - 1,
                            suffix: '日',
                            padZero: true,
                            onChanged: (idx) => selectedDay = days[idx],
                          ),
                        const SizedBox(width: 20),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(color: AppColors.divider),
                            ),
                            child: Text('取消', style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [cfg.color, cfg.color.withValues(alpha: 0.8)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(color: cfg.color.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2)),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                onConfirm(DateTime(selectedYear, selectedMonth, selectedDay));
                                Navigator.pop(ctx);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text('确定', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 单列滚轮 + 右侧单位标签（"年"/"月"/"日"）。
  /// 单位只贴在 wheel 内选中那行旁边——视觉上看起来"只有选中的那行带单位"。
  Widget _buildDateWheel({
    required List<int> items,
    required int initialIndex,
    required String suffix,
    required ValueChanged<int> onChanged,
    bool padZero = false,
  }) {
    return Expanded(
      child: Stack(
        alignment: Alignment.center,
        children: [
          ListWheelScrollView.useDelegate(
            controller: FixedExtentScrollController(initialItem: initialIndex),
            itemExtent: 40,
            perspective: 0.003,
            diameterRatio: 1.5,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: onChanged,
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: items.length,
              builder: (ctx, idx) => Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 18),
                  child: Text(
                    padZero ? items[idx].toString().padLeft(2, '0') : '${items[idx]}',
                    style: TextStyle(fontSize: 15, color: AppColors.textPrimary),
                  ),
                ),
              ),
            ),
          ),
          // 右侧固定单位标签（只在视觉上贴住 wheel 中央那行数字）
          Positioned(
            right: 8,
            child: Text(
              suffix,
              style: TextStyle(fontSize: 13, color: AppColors.textTertiary),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 保存按钮区：左"在记一笔"（次按钮，描边），右"保存负债"（主按钮，渐变）
  // ============================================================
  Widget _buildSaveButton(LiabilityTypeConfig config) {
    final enabled = _canSubmit;
    final primaryGradient = enabled
        ? LinearGradient(
            colors: config.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : LinearGradient(
            colors: DebtColors.disabledGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
    final secondaryBorderColor = enabled ? config.color : AppColors.divider;
    final secondaryTextColor = enabled ? config.color : AppColors.textTertiary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // 在记一笔：次按钮（描边 + 浅色背景）
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: enabled
                    ? config.color.withValues(alpha: 0.08)
                    : AppColors.background,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: secondaryBorderColor, width: 1.2),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: enabled ? () => _submit(closeAfter: false) : null,
                  borderRadius: BorderRadius.circular(25),
                  child: Center(
                    child: Text(
                      '在记一笔',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: secondaryTextColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 保存负债：主按钮（实心渐变）
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                gradient: primaryGradient,
                borderRadius: BorderRadius.circular(25),
                boxShadow: enabled
                    ? [
                        BoxShadow(
                          color: config.color.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: enabled ? () => _submit(closeAfter: true) : null,
                  borderRadius: BorderRadius.circular(25),
                  child: const Center(
                    child: Text(
                      '保存负债',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 工具
  // ============================================================
  Color _parseHexColor(String colorStr) {
    try {
      return Color(int.parse(colorStr.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppColors.primary;
    }
  }

  IconData _parseIcon(String iconName) {
    const iconMap = {
      'credit_card': Icons.credit_card,
      'payments': Icons.payments,
      'account_balance': Icons.account_balance,
      'account_balance_wallet': Icons.account_balance_wallet,
      'payments_outlined': Icons.payments_outlined,
      'wallet': Icons.wallet,
      'shopping_cart': Icons.shopping_cart,
      'shopping_bag': Icons.shopping_bag,
    };
    return iconMap[iconName] ?? Icons.payment;
  }
}
