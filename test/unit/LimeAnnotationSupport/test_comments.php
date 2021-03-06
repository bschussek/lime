<?php

/*
 * This file is part of the Lime framework.
 *
 * (c) Fabien Potencier <fabien.potencier@symfony-project.com>
 * (c) Bernhard Schussek <bernhard.schussek@symfony-project.com>
 *
 * This source file is subject to the MIT license that is bundled
 * with this source code in the file LICENSE.
 */

require_once dirname(__FILE__).'/setup.php';

LimeAnnotationSupport::enable();

$t = new LimeTest();

// @Test
echo "Test 1\n";

// @Test: This test is commented with "double" and 'single' quotes
echo "Test 2\n";
