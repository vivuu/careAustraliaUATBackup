'use strict';

var stripe = Stripe('pk_test_51LIkLGGGWgtqSxG4cRH6iYe1YhS3yFvRtDiJWV6p3bn0yW7frcQy9E4wWH3EkrTaK3WCEpaV9AkzCSwWhPANh4nd00zdRikbTT');

function registerElements(elements, exampleName) {
  var formClass = '.' + exampleName;
  var example = document.querySelector(formClass);

  var form = example.querySelector('form');
  var error = form.querySelector('.error');
  var errorMessage = error.querySelector('.message');

  



 

  

  // Listen on the form's 'submit' handler...
  form.addEventListener('submit', function(e) {
    e.preventDefault();

    

    // Use Stripe.js to create a token. We only need to pass in one Element
    // from the Element group in order to create a token. We can also pass
    // in the additional customer data we collected in our form.
    stripe.createPaymentMethod({card:elements[0],type:'card'}).then(function(result) {
      

      if (result) {
        console.log(JSON.stringify(result));
        alert(JSON.stringify(result));
      } else {
        alert('fails');
      }
    });
  });

 
}
