import 'package:active_ecommerce_flutter/custom/box_decorations.dart';
import 'package:active_ecommerce_flutter/custom/enum_classes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/screens/order_list.dart';
import 'package:active_ecommerce_flutter/screens/payment_method_screen/stripe_screen.dart';
import 'package:active_ecommerce_flutter/screens/payment_method_screen/paypal_screen.dart';
import 'package:active_ecommerce_flutter/screens/payment_method_screen/razorpay_screen.dart';
import 'package:active_ecommerce_flutter/screens/payment_method_screen/paystack_screen.dart';
import 'package:active_ecommerce_flutter/screens/payment_method_screen/iyzico_screen.dart';
import 'package:active_ecommerce_flutter/screens/payment_method_screen/bkash_screen.dart';
import 'package:active_ecommerce_flutter/screens/payment_method_screen/nagad_screen.dart';
import 'package:active_ecommerce_flutter/screens/payment_method_screen/sslcommerz_screen.dart';
import 'package:active_ecommerce_flutter/screens/payment_method_screen/flutterwave_screen.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/repositories/payment_repository.dart';
import 'package:active_ecommerce_flutter/repositories/cart_repository.dart';
import 'package:active_ecommerce_flutter/repositories/coupon_repository.dart';
import 'package:active_ecommerce_flutter/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:toast/toast.dart';
import 'package:active_ecommerce_flutter/screens/payment_method_screen/offline_screen.dart';
import 'package:active_ecommerce_flutter/screens/payment_method_screen/paytm_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'cart.dart';

class Checkout extends StatefulWidget {
  int order_id; // only need when making manual payment from order details
  String list;

  //final OffLinePaymentFor offLinePaymentFor;
  final PaymentFor paymentFor;
  final double rechargeAmount;
  final String title;
  var packageId;
String total;
int conter;
  Checkout(
      {Key key,
        this.total,
      this.order_id = 0,
      this.paymentFor,
      this.list = "both",
      //this.offLinePaymentFor,
      this.rechargeAmount = 0.0,
      this.title,
        this.conter,
      this.packageId = 0})
      : super(key: key);

  @override
  _CheckoutState createState() => _CheckoutState(total,conter);
}

class _CheckoutState extends State<Checkout> {
  var _selected_payment_method_index = 0;
  var _selected_payment_method = "manual_payment";
  var _selected_payment_method_key = "manual_payment";
var toto;
  ScrollController _mainScrollController = ScrollController();
  TextEditingController _couponController = TextEditingController();
  var _paymentTypeList = [];
  bool _isInitial = true;
  var _totalString = ". . .";

  var _subTotalString = ". . .";
  var _taxString = ". . .";
  var _shippingCostString = ". . .";
  var _discountString = ". . .";
  var _used_coupon_code = "";
  var _coupon_applied = false;
  BuildContext loadingcontext;
  String payment_type = "cart_payment";
  String _title;
  int counter;
  bool selected=false;

  _CheckoutState(String total, int conter)
  {
    this.toto=total;
    this.counter=conter;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    String extractedNumber = extractNumbers(toto);

    final double _grandTotalValue =double.parse('$extractedNumber');

    fetchAll();
    print("zezo");
  }
  String extractNumbers(String input) {
    RegExp regex = RegExp(r'(\d+(\.\d+)?)'); // Regular expression to match numbers

    Match match = regex.firstMatch(input); // Find the first match in the input string

    if (match != null) {
      String numberString = match.group(0); // Get the matched number string
      return numberString.replaceAll(RegExp(r'[^0-9.]'), ''); // Remove any non-digit and non-decimal point characters
    }

    return null; // Return null if no number is found in the input string
  }

  @override
  void dispose() {
    super.dispose();
    _mainScrollController.dispose();
  }

  fetchAll() {

        fetchSummary();

    }



  fetchSummary() async {
    var cartSummaryResponse = await CartRepository().getCartSummaryResponse();

    if (cartSummaryResponse != null) {
      _subTotalString = cartSummaryResponse.sub_total;
      _taxString = cartSummaryResponse.tax;
      _shippingCostString = cartSummaryResponse.shipping_cost;
      _discountString = cartSummaryResponse.discount;
      _totalString = cartSummaryResponse.grand_total;
      _used_coupon_code = cartSummaryResponse.coupon_code;
      _couponController.text = _used_coupon_code;
      _coupon_applied = cartSummaryResponse.coupon_applied;
      setState(() {});
    }
  }

  reset() {
    _paymentTypeList.clear();
    _isInitial = true;
    _selected_payment_method_index = 0;
    _selected_payment_method = "manual_payment";
    _selected_payment_method_key = "manual_payment";
    setState(() {});

    reset_summary();
  }

  reset_summary() {
    _totalString = ". . .";
    _subTotalString = ". . .";
    _taxString = ". . .";
    _shippingCostString = ". . .";
    _discountString = ". . .";
    _used_coupon_code = "";
    _couponController.text = _used_coupon_code;
    _coupon_applied = false;

    setState(() {});
  }

  Future<void> _onRefresh() async {
    reset();
    fetchAll();
  }

  onPopped(value) {
    reset();
    fetchAll();
  }

  onCouponApply() async {
    var coupon_code = _couponController.text.toString();
    if (coupon_code[0] !='g' &&  coupon_code[0] !='G' ) {
      ToastComponent.showDialog(
        "this coupon in invalid ",
          gravity: Toast.center,
          duration: Toast.lengthLong);
      return;
    }
    else if (coupon_code == "") {
      ToastComponent.showDialog(
          AppLocalizations.of(context).checkout_screen_coupon_code_warning,
          gravity: Toast.center,
          duration: Toast.lengthLong);
      return;
    }else  if (coupon_code[0] == 'g' && counter>1) {
      ToastComponent.showDialog(
          "this coupon is only valid for one single selected product only",
          gravity: Toast.center,
          duration: Toast.lengthLong);
      return;
    }
    else  if (coupon_code[0] == 'g') {
      selected=true;
    }



    var couponApplyResponse =
        await CouponRepository().getCouponApplyResponse(coupon_code);
    if (couponApplyResponse.result == false) {
      ToastComponent.showDialog(couponApplyResponse.message,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }

    reset_summary();
    fetchSummary();
  }



  onPressPlaceOrderOrProceed() {

    if (toto == 0.00) {
      ToastComponent.showDialog(
          AppLocalizations.of(context).common_nothing_to_pay,
          gravity: Toast.center,
          duration: Toast.lengthLong);
      return;
    }
    else{
      pay_by_manual_payment();}

  }


  pay_by_manual_payment() async {
    loading();
    var orderCreateResponse = await PaymentRepository()
        .getOrderCreateResponseFromManualPayment(_selected_payment_method_key);
    Navigator.pop(loadingcontext);
    if (orderCreateResponse.result == false) {
      ToastComponent.showDialog(orderCreateResponse.message,
          gravity: Toast.center, duration: Toast.lengthLong);
      Navigator.of(context).pop();
      return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return OrderList(from_checkout: true );
    }));
  }





  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: app_language_rtl.$ ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: buildAppBar(context),
          bottomNavigationBar: buildBottomAppBar(context),
          body: Stack(
            children: [
              RefreshIndicator(
                color: MyTheme.accent_color,
                backgroundColor: Colors.white,
                onRefresh: _onRefresh,
                displacement: 0,
                child: CustomScrollView(
                  controller: _mainScrollController,
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  slivers: [
                    SliverList(
                      delegate: SliverChildListDelegate([
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: buildPaymentMethodList(),
                        ),
                        Container(
                          height: 140,
                        )
                      ]),
                    )
                  ],
                ),
              ),

              //Apply Coupon and order details container
              Align(
                alignment: Alignment.bottomCenter,
                child: widget.paymentFor == PaymentFor.WalletRecharge ||
                        widget.paymentFor == PaymentFor.PackagePay
                    ? Container()
                    : Container(
                        decoration: BoxDecoration(
                          color: Colors.white,

                          /*border: Border(
                      top: BorderSide(color: MyTheme.light_grey,width: 1.0),
                    )*/
                        ),
                        height: widget.paymentFor == PaymentFor.ManualPayment
                            ? 80
                            : 140,
                        //color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              widget.paymentFor == PaymentFor.Order
                                  ? Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 16.0),
                                      child: buildApplyCouponRow(context),
                                    )
                                  : Container(),
                              grandTotalSection(),
                            ],
                          ),
                        ),
                      ),
              )
            ],
          )),
    );
  }

  Row buildApplyCouponRow(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 42,
          width: (MediaQuery.of(context).size.width - 32) * (2 / 3),
          child: TextFormField(
            controller: _couponController,
            readOnly: _coupon_applied,
            autofocus: false,
            decoration: InputDecoration(
                hintText: AppLocalizations.of(context)
                    .checkout_screen_enter_coupon_code,
                hintStyle:
                    TextStyle(fontSize: 14.0, color: MyTheme.textfield_grey),
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: MyTheme.textfield_grey, width: 0.5),
                  borderRadius: const BorderRadius.only(
                    topLeft: const Radius.circular(8.0),
                    bottomLeft: const Radius.circular(8.0),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: MyTheme.medium_grey, width: 0.5),
                  borderRadius: const BorderRadius.only(
                    topLeft: const Radius.circular(8.0),
                    bottomLeft: const Radius.circular(8.0),
                  ),
                ),
                contentPadding: EdgeInsets.only(left: 16.0)),
          ),
        ),
        !_coupon_applied
            ? Container(
                width: (MediaQuery.of(context).size.width - 32) * (1 / 3),
                height: 42,
                child: FlatButton(
                  minWidth: MediaQuery.of(context).size.width,
                  //height: 50,
                  color: MyTheme.accent_color,
                  shape: RoundedRectangleBorder(
                      borderRadius: const BorderRadius.only(
                    topRight: const Radius.circular(8.0),
                    bottomRight: const Radius.circular(8.0),
                  )),
                  child: Text(
                    AppLocalizations.of(context).checkout_screen_apply_coupon,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                    onCouponApply();
                  },
                ),
              )
            : Container(
                width: (MediaQuery.of(context).size.width - 32) * (1 / 3),
                height: 42,
                child: FlatButton(
                  minWidth: MediaQuery.of(context).size.width,
                  //height: 50,
                  color: MyTheme.accent_color,
                  shape: RoundedRectangleBorder(
                      borderRadius: const BorderRadius.only(
                    topRight: const Radius.circular(8.0),
                    bottomRight: const Radius.circular(8.0),
                  )),
                  child: Text(
                    AppLocalizations.of(context).checkout_screen_remove,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                  //  onCouponRemove();
                  },
                ),
              )
      ],
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: true,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(CupertinoIcons.arrow_left, color: MyTheme.dark_grey),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      title: Text(
        widget.title,
        style: TextStyle(fontSize: 16, color: MyTheme.accent_color),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }

  static bool k = false;
  static bool x = false;
  static bool y = false;
  int _paymentType = 1;

  buildPaymentMethodList() {
    return ListView(
      shrinkWrap: true,
      children: [


        RadioListTile(
          value: 3,
          title: const Text("Payment by cash on delviery"),
          groupValue: _paymentType,
          onChanged: (val) => setState(() {
            _paymentType = val;
          }),
        ),
      ],
    );

  }




  BottomAppBar buildBottomAppBar(BuildContext context) {
    return BottomAppBar(
      child: Container(
        color: Colors.transparent,
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FlatButton(
              minWidth: MediaQuery.of(context).size.width,
              height: 50,
              color: MyTheme.accent_color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0.0),
              ),
              child: Text(
                widget.paymentFor == PaymentFor.WalletRecharge
                    ? AppLocalizations.of(context)
                        .recharge_wallet_screen_recharge_wallet
                    : widget.paymentFor == PaymentFor.ManualPayment
                        ? AppLocalizations.of(context)
                            .common_proceed_in_all_caps
                        : widget.paymentFor == PaymentFor.PackagePay
                            ? AppLocalizations.of(context)
                                .checkout_screen_buy_package
                            : AppLocalizations.of(context)
                                .checkout_screen_place_my_order,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
              onPressed: () {
                onPressPlaceOrderOrProceed();
              },
            )
          ],
        ),
      ),
    );
  }


  Widget grandTotalSection() {
    return Container(
      height: 40,
      width: double.infinity,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: MyTheme.soft_accent_color),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                AppLocalizations.of(context).checkout_screen_total_amount,
                style: TextStyle(color: MyTheme.font_grey, fontSize: 14),
              ),
            ),
            Visibility(
              visible: widget.paymentFor != PaymentFor.ManualPayment,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Money Amount'),
                          content: Text('your charge \ ${toto}'),
                          actions: <Widget>[
                            FlatButton(
                              child: Text('Close'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text(
                    AppLocalizations.of(context).common_see_details,
                    style: TextStyle(
                      color: MyTheme.font_grey,
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),

              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                  widget.paymentFor == PaymentFor.ManualPayment
                      ? widget.rechargeAmount.toString()
                      : _totalString,
                  style: TextStyle(
                      color: MyTheme.accent_color,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  loading() {
    showDialog(
        context: context,
        builder: (context) {
          loadingcontext = context;
          return AlertDialog(
              content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(
                width: 10,
              ),
              Text("${AppLocalizations.of(context).loading_text}"),
            ],
          ));
        });
  }
}
