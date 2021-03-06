/*
 * This file is part of the Lime framework.
 *
 * (c) Fabien Potencier <fabien.potencier@symfony-project.com>
 * (c) Bernhard Schussek <bernhard.schussek@symfony-project.com>
 *
 * This source file is subject to the MIT license that is bundled
 * with this source code in the file LICENSE.
 */

<?php echo $class_declaration ?>  
{
  private
    $class            = null,
    $state            = null,
    $invocationTrace  = null,
    $behaviour    	  = null,
    $stubMethods      = true;
  
  public function __construct($class, LimeMockBehaviourInterface $behaviour, $stubMethods = true)
  {
    $this->class = $class;
    $this->behaviour = $behaviour;
    $this->stubMethods = $stubMethods;
    $this->invocationTrace = new LimeMockInvocationTrace();
    
    $this->__lime_reset();
  }
  
  public function __call($method, $parameters)
  {
    try
    {
      $method = new LimeMockMethod($this->class, $method);
      
      // if $stubMethods is set to FALSE, methods that are not configured are
      // passed to the real implementation
      if ($this->stubMethods || $this->state->isInvokable($method))
      {
        return $this->state->invoke($method, $parameters);
      }
      else if (method_exists($this->class, $method->getMethod()))
      {
        // THIS METHOD CALL WILL LEAD TO SEGFAULTS WHEN EXECUTED IN A 
        // WEBSERVER ENVIRONMENT!!!
        
        if (PHP_VERSION_ID < 50300)
        {
	      return call_user_func_array(array($this, 'parent::'.$method->getMethod()), $parameters);
	    }
	    else
	    {
          return call_user_func_array('parent::'.$method->getMethod(), $parameters);
        }
      }
    }
    catch (LimeMockInvocationException $e)
    {
      // hide the internal trace to not distract when debugging test errors
      throw new LimeMockException($this, $e);
    }
  }
  
  public function __lime_replay()
  {
    $this->state = new LimeMockReplayState($this->behaviour);
  }
  
  public function __lime_reset()
  {
    $this->behaviour->reset();
    
    if (!$this->state instanceof LimeMockRecordState)
    {
      $this->state = new LimeMockRecordState($this->behaviour, $this->invocationTrace);
    }
  }
  
  public function __lime_verify()
  {
    try
    {
      return $this->state->verify();
    }
    catch (LimeMockInvocationException $e)
    {
      // hide the internal trace to not distract when debugging test errors
      throw new LimeMockException($this, $e);
    }
  }
  
  public function __lime_setExpectNothing()
  {
    return $this->state->setExpectNothing();
  }
  
  public function __lime_getInvocationTrace()
  {
    return $this->invocationTrace;
  }
  
  <?php if ($generate_controls): ?>
  public function replay() { return LimeMock::replay($this); }
  public function method($methodName) { return LimeMock::method($this, $methodName); }
  public function reset() { return LimeMock::reset($this); }
  public function verify() { return LimeMock::verify($this); }
  public function setExpectNothing() { return LimeMock::setExpectNothing($this); }
  <?php endif ?>
  
  <?php echo $methods ?> 
}