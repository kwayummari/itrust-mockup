String currency(val){
  
    int step = 1;

    
    for (var i = val.length-1; i >=0; i--) {
      if (i - 2*step > 0) {
        
        val = val.replaceRange(i-2*step, i-2*step, ",");
        step++;
      }
    }

    
    
    return "$val";
  }
