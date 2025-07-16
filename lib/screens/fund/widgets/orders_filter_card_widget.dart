
import 'package:flutter/material.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/models/IPO/subscription.dart';
import 'package:iwealth/screens/fund/widgets/show_datepicker.dart';
import 'package:intl/intl.dart';
import 'package:iwealth/screens/user/biometric_verification_screen.dart';
import 'package:iwealth/stocks/models/bond_orders_model.dart';

import '../../../stocks/models/order.dart';
import 'order_list_widget.dart';

class OrdersFilterCardWidget extends StatefulWidget {
  final bool filterOpened;
  final Function onApply;
  final VoidCallback onReset;
  final List orders;
  const OrdersFilterCardWidget({super.key, required this.filterOpened, required this.onApply, required this.orders, required this.onReset});

  @override
  State<OrdersFilterCardWidget> createState() => _OrdersFilterCardWidgetState();
}

class _OrdersFilterCardWidgetState extends State<OrdersFilterCardWidget> {

  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  String? category;
  List<String> categories = [ 'buy', 'sale'
  ];
  String? status;
  List<String> statuses = [
    'pending',
    'submitted',
    'failed',
  ];


  List _applyFilters(data){

    var filter = data;
    if(startDate != null) {
      filter =  filter.where((order) {
        return OrderListWidget.parsedDate(order.date)
            .compareTo(startDate!) >=
            0 ;
      }).toList();
    }
    if(endDate != null) {
      filter =  filter.where((order) {
        return  OrderListWidget.parsedDate(order.date)
                .compareTo(endDate!) <=
                0;
      }).toList();
    }
    if(category != null){
      filter =
          filter.where((order) {
            String orderCategory = '';
            if(order is IPOSubscription){
              orderCategory = order.transactionType;
            }
            if(order is BondOrder) {
              orderCategory = order.type;
            }
            if(order is Order) {
              orderCategory = order.orderType ?? '';
            }
            return orderCategory.toLowerCase() ==
                category;
          }).toList();
    }

   return filter;

  }


  Widget dateField(BuildContext context,
      {required String label}) {
    final isStartDate = label == 'Start Date';
    final displayDate = isStartDate ? startDate : endDate;

    final date = isStartDate ? startDate ?? DateTime.now().subtract(const Duration(days: 30)) : endDate ?? DateTime.now();
    return GestureDetector(
      onTap:  () async {
        final DateTime? picked =
        await showMyDatePicker(context, date,
            maxDate: isStartDate ? DateTime.now().subtract(
                const Duration(days: 1)) : DateTime.now());
        if (picked != null) {
          setState(() {
            if(isStartDate) {
              startDate = picked;
            } else {
              endDate = picked;
            }
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColor().inputFieldColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  displayDate == null ? label : DateFormat('dd MMM yyyy').format(displayDate),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:FontWeight.w400,
                    color: displayDate == null ? AppColor().grayText: AppColor().textColor,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.calendar_today_outlined,
                  color: AppColor().grayText,
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioOption(
      String value, String label, String? groupValue, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Row(
        children: [
          SizedBox(
            height: 36,
            child: Radio(
              value: value,
              groupValue: groupValue,
              activeColor: AppColor().blueBTN,
              onChanged: (_) {onTap();},
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColor().textColor,
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      child: !widget.filterOpened
          ? const SizedBox(
              width: double.infinity,
            )
          : SizedBox(
              width: double.infinity,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Filter Options',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColor().textColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColor().lowerBg,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppColor().textColor,
                            ),
                          ),

                          Row(
                            children: [
                              Expanded(
                                child: dateField(context,
                                    label: 'Start Date',)),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: dateField(context,
                                      label: 'End Date'
                               )),
                            ],
                          ),

                          const SizedBox(height: 16),
                          Text(
                            'Category',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppColor().textColor,
                            ),
                          ),
                          Row(
                            children: categories.map((cat) {
                              return Expanded(
                                child: _buildRadioOption(
                                    cat, cat.capitalize(), category, () {
                                  setState(() {
                                    category = cat;
                                  });
                                }),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 8),
                          // Text( 'Status',
                          //   style: TextStyle(
                          //     fontSize: 16,
                          //     fontWeight: FontWeight.w600,
                          //     color: AppColor().textColor,
                          //   ),),
                          //       GridView.builder(
                          //           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          //             crossAxisCount: 2,
                          //             childAspectRatio: 16/3.5
                          //           ),
                          //           shrinkWrap: true,
                          //           physics: NeverScrollableScrollPhysics(),
                          //           itemCount: statuses.length,
                          //           itemBuilder: (BuildContext context, int index) {
                          //                 return _buildRadioOption(statuses[index], statuses[index].capitalize(), status, () {
                          //                   setState(() {
                          //                     status = statuses[index];
                          //                   });
                          //                 });
                          //           }
                          //       ),

                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: (){
                                    setState(() {
                                      status = null;
                                      category = null;
                                       startDate = null;
                                       endDate = null;
                                    });
                                    widget.onApply(_applyFilters(widget.orders));
                                    widget.onReset();
                                    },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColor().orangeApp,
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  child:const Text('Reset'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                  child: ElevatedButton(
                                    onPressed: ()=>                                    widget.onApply(_applyFilters(widget.orders)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColor().blueBTN,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                      textStyle: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                    child: const Text('Apply'),
                                  ))
                            ],
                          ),

                        ],
                      ),
                    ),

                  ],
                ),
              ),
            ),
    );
  }

}
