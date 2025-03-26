import modal from '../utils/modal';
import { computed } from '@ember/object';

export default modal.ModalController.extend({
  version: computed(function() {
    return (window.SweetSuite && window.SweetSuite.update_version) || 'unknown';
  }),
  actions: {
    restart: function() {
      if(window.SweetSuite && window.SweetSuite.install_update) {
        window.SweetSuite.install_update();
      } else {
        this.set('error', true);
      }
    }
  }
});
