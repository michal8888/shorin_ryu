// StripeChecout not defined -- turbolinks:load instead of document.ready

$(document).on("turbolinks:load", function(){
  if ($("body").attr("class") == "checkouts") {
    $("#use_delivery_address").on("click", function(){
      var array = [];
      CollectDeliveryAddress(array);
      PasteBillingAddress(array);
    });
    
    $("#from_delivery_method").on("click", function(){
      $(".delivery_method").hide();
      $(".delivery_address").show();
      $("#to_delivery_method").show();
      $("#from_delivery_address").show();
      $(this).hide();
    });
    
    $("#to_delivery_method").on("click", function(){
      $(".delivery_method").show();
      $(".delivery_address").hide();
      $("#to_delivery_method").hide();
      $("#from_delivery_address").hide();
      $(this).hide();
      $("#from_delivery_method").show();
    });
  
    $("#from_delivery_address").on("click", function(){
      $(".billing_address").show();
      $(".delivery_address").hide();
      $("#use_delivery_address").show();
      $(this).hide();
      $("#to_delivery_method").hide();
      $("#to_delivery_address").show();
      $("#from_billing_address").show();
    });
    
    $("#to_delivery_address").on("click", function(){
      $(".billing_address").hide();
      $(".delivery_address").show();
      $("#use_delivery_address").hide();
      $("#submit_form").hide();
      $(this).hide();
      $("#to_delivery_method").show();
      $("#from_delivery_address").show();
      $("#from_billing_address").hide();
    });
    
    $("#from_billing_address").on("click", function(){
      $(".payment_method").show();
      $("#to_billing_address").show();
      $("#to_delivery_address").hide();
      $("#use_delivery_address").hide();
      $(".billing_address").hide();
      $("#submit_form").show();
      $(this).hide();
    });
    
    $("#to_billing_address").on("click", function(){
      $(".payment_method").hide();
      $("#submit_form").hide();
      $(this).hide();
      $("#to_delivery_address").show();
      $("#from_billing_address").show();
      $(".billing_address").show();
    });
  
    var handler = StripeCheckout.configure({
      key: "pk_test_GQq9bxu7aMfrR0YCsfw86ZYF",
      image: 'https://stripe.com/img/documentation/checkout/marketplace.png',
      locale: 'auto',
      token: function(token) {
        console.log(token);
      }
    });
    
    var money = Number($("#total_price").text());
    var delivery = 19.90;
  
    $("#checkout_delivery_method_1").on("click", function(){
      delivery = 19.90;
    });
    
    $("#checkout_delivery_method_2").on("click", function(){
      delivery = 29.90;
    });
  
    document.getElementById('creditCardButton').addEventListener('click', function(e) {
      // Open Checkout with further options:
      handler.open({
        name: 'Stripe.com',
        // description: '2 widgets',
        // zipCode: true,
        amount: (money + delivery) * 100,
        currency: "PLN"  
      });
      e.preventDefault();
    });
    
    window.addEventListener('popstate', function() {
      handler.close();
    });
  
    var seller_business = "bihone-facilitator@wp.pl";
    var buyer_personal = "bihone-buyer@wp.pl";
    
    paypal.Button.render({
      // env: 'production', // Or 'sandbox',
      env: 'sandbox', // Or 'sandbox',
      
      client: {
        sandbox:    'AYp013VvGi4nnls3I0d4z3Ldh9aqQDCBuQKc3oEPP8T62pAmXtFbubzgJYM3fye7G0UwS-hmeJEuPNJ6',
        production: 'ARY1D7-mGduukgDRp3qA9RhMh9ZuFgWnJ8Ze80GosNDtAXdZJCS6huV0Jb_goGtlqb1aL1oBZLaY4Dhz'
      },
  
      commit: true, // Show a 'Pay Now' button
  
      style: {
        color: 'black',
        size: 'small'
      },
  
      payment: function(data, actions) {
        console.log("payment");
        return actions.payment.create({
          payment: {
            transactions: [{
              amount: { total: money + delivery, currency: "PLN" }
            }]   
          }
        });
      },
  
  
  
      onAuthorize: function(data, actions) {
        console.log("authorize");
        return actions.payment.execute().then(function(payment){
          console.log("DONE");
        });
      },
  
      onCancel: function(data, actions) {
        /* 
         * Buyer cancelled the payment 
         */
         console.log("cancel");
      },
  
      onError: function(err) {
        /* 
         * An error occurred during the transaction 
         */
         console.log("error");
      }
    }, '#paypal-button');
  }
});

function CollectDeliveryAddress(arr){
  $(".delivery_address input").each(function(){
    arr.push($(this).val());
  });  
}

function PasteBillingAddress(arr){
  $(".billing_address input").each(function(){
    $(this).val(arr.shift());
  });  
}