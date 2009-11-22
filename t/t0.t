#!/usr/env perl

# $Id: t0.t 12 2009-11-22 01:15:52Z stro $

use strict;
use warnings;

BEGIN {
	use Test;
	plan('tests' => 1);
}

use WWW::DreamHost::API;

ok(1); # sanity check and other modules skipping workaround
