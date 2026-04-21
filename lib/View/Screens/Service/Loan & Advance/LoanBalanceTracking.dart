import 'package:flutter/material.dart';
import '../../../../utils/colers.dart';

class Loanbalancetracking extends StatefulWidget {
  const Loanbalancetracking({super.key});

  @override
  State<Loanbalancetracking> createState() => _LoanbalancetrackingState();
}

class _LoanbalancetrackingState extends State<Loanbalancetracking> {
  // Sample loan data
  final Map<String, dynamic> loanDetails = {
    'loanId': 'LN2024001',
    'loanType': 'Personal Loan',
    'principalAmount': 200000.00,
    'interestRate': 10.5,
    'tenure': 24,
    'startDate': '15 Jan 2024',
    'endDate': '15 Jan 2026',
    'emiAmount': 9250.00,
    'nextEmiDate': '15 Mar 2024',
    'totalPaid': 18500.00,
    'totalRemaining': 181500.00,
    'paidEmis': 2,
    'totalEmis': 24,
    'status': 'Active',
  };

  final List<Map<String, dynamic>> transactionHistory = [
    {
      'date': '15 Feb 2024',
      'description': 'EMI Payment - Feb 2024',
      'amount': 9250.00,
      'status': 'Paid',
      'type': 'debit',
      'reference': 'TXN2024021501',
    },
    {
      'date': '15 Jan 2024',
      'description': 'EMI Payment - Jan 2024',
      'amount': 9250.00,
      'status': 'Paid',
      'type': 'debit',
      'reference': 'TXN2024011501',
    },
    {
      'date': '10 Jan 2024',
      'description': 'Loan Disbursement',
      'amount': 200000.00,
      'status': 'Credited',
      'type': 'credit',
      'reference': 'DIS2024011001',
    },
  ];

  final List<Map<String, dynamic>> upcomingEmis = [
    {
      'date': '15 Mar 2024',
      'amount': 9250.00,
      'status': 'Pending',
      'daysLeft': 18,
    },
    {
      'date': '15 Apr 2024',
      'amount': 9250.00,
    'status': 'Pending',
      'daysLeft': 49,
    },
    {
      'date': '15 May 2024',
      'amount': 9250.00,
    'status': 'Pending',
      'daysLeft': 80,
    },
  ];

  String _selectedTab = 'overview'; // overview, transactions, upcoming

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Loan Balance Tracking"),
        backgroundColor: primary_color,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              _showDownloadOptions();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _refreshData();
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
        ),
        child: Column(
          children: [
            // Loan Summary Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primary_color, primary_color.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: primary_color.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Loan ID: ${loanDetails['loanId']}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            loanDetails['loanType'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          loanDetails['status'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Amount Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSummaryItem(
                        'Principal',
                        '₹${loanDetails['principalAmount'].toStringAsFixed(0)}',
                        Icons.account_balance,
                      ),
                      Container(
                        height: 40,
                        width: 1,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      _buildSummaryItem(
                        'Paid',
                        '₹${loanDetails['totalPaid'].toStringAsFixed(0)}',
                        Icons.check_circle,
                      ),
                      Container(
                        height: 40,
                        width: 1,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      _buildSummaryItem(
                        'Remaining',
                        '₹${loanDetails['totalRemaining'].toStringAsFixed(0)}',
                        Icons.pending,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Progress Bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${loanDetails['paidEmis']}/${loanDetails['totalEmis']} EMIs Paid',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${((loanDetails['paidEmis'] / loanDetails['totalEmis']) * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: loanDetails['paidEmis'] / loanDetails['totalEmis'],
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Tab Selector
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _buildTabButton('Overview', 'overview'),
                  _buildTabButton('Transactions', 'transactions'),
                  _buildTabButton('Upcoming', 'upcoming'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Content based on selected tab
            Expanded(
              child: _buildTabContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white70,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTabButton(String label, String tabValue) {
    bool isSelected = _selectedTab == tabValue;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = tabValue;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? primary_color : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade600,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 'overview':
        return _buildOverviewTab();
      case 'transactions':
        return _buildTransactionsTab();
      case 'upcoming':
        return _buildUpcomingTab();
      default:
        return _buildOverviewTab();
    }
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Loan Details Card
          _buildInfoCard(
            'Loan Details',
            Icons.info_outline,
            [
              _buildInfoRow('Loan ID', loanDetails['loanId']),
              _buildInfoRow('Loan Type', loanDetails['loanType']),
              _buildInfoRow('Interest Rate', '${loanDetails['interestRate']}%'),
              _buildInfoRow('Tenure', '${loanDetails['tenure']} months'),
              _buildInfoRow('Start Date', loanDetails['startDate']),
              _buildInfoRow('End Date', loanDetails['endDate']),
            ],
          ),

          const SizedBox(height: 16),

          // EMI Details Card
          _buildInfoCard(
            'EMI Details',
            Icons.calendar_month,
            [
              _buildInfoRow('EMI Amount', '₹${loanDetails['emiAmount'].toStringAsFixed(2)}'),
              _buildInfoRow('Next EMI Date', loanDetails['nextEmiDate']),
              _buildInfoRow('EMIs Paid', '${loanDetails['paidEmis']}/${loanDetails['totalEmis']}'),
              _buildInfoRow('Total Paid', '₹${loanDetails['totalPaid'].toStringAsFixed(2)}'),
              _buildInfoRow('Total Remaining', '₹${loanDetails['totalRemaining'].toStringAsFixed(2)}'),
            ],
          ),

          const SizedBox(height: 16),

          // Quick Actions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildActionButton(
                      'Pay EMI',
                      Icons.payment,
                          () {},
                    ),
                    _buildActionButton(
                      'Statement',
                      Icons.description,
                          () {},
                    ),
                    _buildActionButton(
                      'Prepay',
                      Icons.currency_rupee,
                          () {},
                    ),
                    _buildActionButton(
                      'Contact',
                      Icons.support_agent,
                          () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: transactionHistory.length,
      itemBuilder: (context, index) {
        final transaction = transactionHistory[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    transaction['date'],
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: transaction['status'] == 'Paid'
                          ? Colors.green.withOpacity(0.1)
                          : Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      transaction['status'],
                      style: TextStyle(
                        color: transaction['status'] == 'Paid'
                            ? Colors.green
                            : Colors.blue,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: transaction['type'] == 'credit'
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      transaction['type'] == 'credit'
                          ? Icons.call_received
                          : Icons.call_made,
                      color: transaction['type'] == 'credit'
                          ? Colors.green
                          : Colors.orange,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction['description'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ref: ${transaction['reference']}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${transaction['type'] == 'credit' ? '+' : '-'}₹${transaction['amount'].toStringAsFixed(2)}',
                    style: TextStyle(
                      color: transaction['type'] == 'credit'
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUpcomingTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: upcomingEmis.length,
      itemBuilder: (context, index) {
        final emi = upcomingEmis[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primary_color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.calendar_today,
                  color: primary_color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Due: ${emi['date']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Amount: ₹${emi['amount'].toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${emi['daysLeft']} days left',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    emi['status'],
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: primary_color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primary_color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: primary_color,
              size: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  void _showDownloadOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Download Statement',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildDownloadOption('Last 3 months', Icons.three_k),
                _buildDownloadOption('Last 6 months', Icons.six_k),
                _buildDownloadOption('Last 1 year', Icons.twelve_mp),
                _buildDownloadOption('Full statement', Icons.calendar_view_month),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDownloadOption(String label, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: primary_color),
      title: Text(label),
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Downloading $label...'),
            backgroundColor: primary_color,
          ),
        );
      },
    );
  }

  void _refreshData() {
    setState(() {
      // Refresh data logic here
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data refreshed successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }
}