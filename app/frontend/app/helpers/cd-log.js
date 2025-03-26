import SweetSuite from '../app';

import { helper } from '@ember/component/helper';

export default helper(function(params, hash) {
  if(SweetSuite.log.started) {
    SweetSuite.log.track(params[0]);
  } else {
    console.log(params[0]);
  }
  return "";
});
