queuemodel=function(lambda,b,c)
{ 
  queue=0;
  iteration=0;
  
  while(TRUE)
  {
    queue=queue+rpois(1,lambda);
    iteration=iteration+1;
    
    if(queue>b)
    {
      return(iteration);
    }
    
    else
    {
      queue=max(queue-c,0);
    }
  }
}
