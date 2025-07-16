// import 'package:iwealth/constants/app_color.dart';
// import 'package:iwealth/services/waiter_service.dart';
// import 'package:flutter/material.dart';

// class FundScreen extends StatefulWidget {
//   const FundScreen({super.key});

//   @override
//   State<FundScreen> createState() => _FundScreenState();
// }

// class _FundScreenState extends State<FundScreen> {
//   @override
//   Widget build(BuildContext context) {
//     final double appHeight = MediaQuery.of(context).size.height;
//     final double appWidth = MediaQuery.of(context).size.width;

//     return Scaffold(
//       // backgroundColor: AppColor().mainColor,
//       appBar: AppBar(
//         backgroundColor: AppColor().bgLight,
//         title: Text(
//           "iTrust Mutual Funds",
//           style: TextStyle(
//             color: AppColor().textColor,
//             fontFamily: "Poppins",
//           ),
//         ),
//       ),
//       body: Container(
//         margin: const EdgeInsets.all(10.0),
//         height: appHeight,
//         width: appWidth,
//         decoration: BoxDecoration(gradient: AppColor().appGradient),
//         child: ListView(
//           children: [
//             Card(
//               color: AppColor().mainColor,
//               elevation: 40.0,
//               surfaceTintColor: AppColor().textColor,
//               child: ListTile(
//                 onTap: () {},
//                 leading: Icon(
//                   Icons.contactless_outlined,
//                   color: AppColor().textColor,
//                 ),
//                 title: Text(
//                   "iTrust Mid-Cap Fund",
//                   style: TextStyle(
//                       fontFamily: "Poppins",
//                       color: AppColor().grayText,
//                       fontSize: 17.0,
//                       fontWeight: FontWeight.w600),
//                 ),
//                 subtitle: Row(
//                   children: [
//                     SizedBox(
//                       child: Column(
//                         children: [
//                           const Text("Min. Invest"),
//                           Text(
//                             "1000 TZS",
//                             style: TextStyle(color: AppColor().textColor),
//                           )
//                         ],
//                       ),
//                     ),
//                     VerticalDivider(
//                       color: AppColor().textColor,
//                       width: 10.0,
//                     ),
//                     SizedBox(
//                       child: Column(
//                         children: [
//                           const Text("Category"),
//                           Text(
//                             "Stock",
//                             style: TextStyle(color: AppColor().textColor),
//                           )
//                         ],
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//             ),
//             Card(
//               color: AppColor().mainColor,
//               elevation: 40.0,
//               surfaceTintColor: AppColor().textColor,
//               child: ListTile(
//                 onTap: () {
//                   Waiter().generateToken();
//                 },
//                 leading: Icon(
//                   Icons.contactless_outlined,
//                   color: AppColor().textColor,
//                 ),
//                 title: Text(
//                   "iGrowth Fund",
//                   style: TextStyle(
//                       fontFamily: "Poppins",
//                       color: AppColor().grayText,
//                       fontSize: 17.0,
//                       fontWeight: FontWeight.w600),
//                 ),
//                 subtitle: Row(
//                   children: [
//                     SizedBox(
//                       child: Column(
//                         children: [
//                           const Text("Min. Invest"),
//                           Text(
//                             "1200 TZS",
//                             style: TextStyle(color: AppColor().textColor),
//                           )
//                         ],
//                       ),
//                     ),
//                     VerticalDivider(
//                       color: AppColor().textColor,
//                       width: 10.0,
//                     ),
//                     SizedBox(
//                       child: Column(
//                         children: [
//                           const Text("Category"),
//                           Text(
//                             "Stock & Bonds",
//                             style: TextStyle(color: AppColor().textColor),
//                           )
//                         ],
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
