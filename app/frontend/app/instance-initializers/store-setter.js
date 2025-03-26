export default {
  name: 'store-setter',
  initialize: function(instance) {
    window.SweetSuite.store = instance.lookup('service:store');
  }
};
