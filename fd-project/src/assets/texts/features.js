// version
if( featureType == -2 )
{
	return 1300.0;
}


// chance
if( featureType == -1 )
{
	return switch ( type )
	{
		case	101	:	0	;
		case	102	:	0	;
		case	103	:	0	;
		case	104	:	0	;
		case	105	:	0	;
		case	106	:	0	;
		case	107	:	0	;
		case	108	:	1	;
		case	109	:	4	;
		case	110	:	12	;
		case	111	:	18	;
		case	112	:	30	;
		case	113	:	40	;
		
		case	151	:	8	;
		case	152	:	10	;
		
		default: 1000;
	}
}

// rarity
if( featureType == 0 )
{
	return switch ( cardType )
	{
		case	101	:	 0	;
		case	102	:	 0	;
		case	103	:	 0	;
		case	104	:	 1	;
		case	105	:	 0	;
		case	106	:	 0	;
		case	107	:	 2	;
		case	108	:	 1	;
		case	109	:	 0	;
		case	110	:	 0	;
		case	111	:	 0	;
		case	112	:	 0	;
		case	113	:	 0	;
		case	114	:	 2	;
		case	115	:	 1	;
		
		case	151	:	 1	;
		case	152	:	 0	;
		case	153	:	 0	;
		case	154	:	 1	;
		case	155	:	 1	;
		case	156	:	 2	;
		case	157	:	 0	;
		case	158	:	 1	;
		case	159	:	 2	;
		
		default		:	 0	;
	}
}


// availableAt
if( featureType == 1 )
{
	return switch( cardType )
	{
		case	101	:	 0	;
		case	102	:	 0	;
		case	103	:	 0	;
		case	104	:	 0	;
		case	105	:	 0	;
		case	106	:	 0	;
		case	107	:	 0	;
		case	108	:	 0	;
		case	109	:	 1	;
		case	110	:	 2	;
		case	111	:	 3	;
		case	112	:	 3	;
		case	113	:	 4	;
		case	114	:	 6	;
		case	115	:	 9	;
		
		case	151	:	 1	;
		case	152	:	 2	;
		case	153	:	 5	;
		case	154	:	 6	;
		case	155	:	 7	;
		case	156	:	 7	;
		case	157	:	 8	;
		case	158	:	 8	;
		case	159	:	 9	;
		
		default		:	 9	;
	}
}


// availableAt
if( featureType == 1 )
{
	return switch( cardType )
	{
		case	101	:	 0	;
		case	102	:	 0	;
		case	103	:	 0	;
		case	104	:	 0	;
		case	105	:	 0	;
		case	106	:	 0	;
		case	107	:	 0	;
		case	108	:	 0	;
		case	109	:	 1	;
		case	110	:	 2	;
		case	111	:	 3	;
		case	112	:	 3	;
		case	113	:	 4	;
		case	114	:	 6	;
		case	115	:	 9	;
		
		case	151	:	 1	;
		case	152	:	 2	;
		case	153	:	 5	;
		case	154	:	 6	;
		case	155	:	 7	;
		case	156	:	 7	;
		case	157	:	 8	;
		case	158	:	 8	;
		case	159	:	 9	;
		
		default		:	 9	;
	}
}


// elixirSize
if( featureType == 2 )
{
	return switch( cardType )
	{
		case 101 :	3	;
		case 102 :	5	;
		case 103 :  4	;
		case 104 :  4	;
		case 105 :  5	;
		case 106 :  4	;
		case 107 :  4	;
		case 108 :  3	;
		case 109 :  4	;
		case 110 :  2	;
		case 111 :  7	;
		case 112 :  4	;
		case 113 :  2	;
		
		case 151 :  4	;
		case 152 :  3	;

		default	 :  2	;
	}
	//return ret;
}


// quantity
if( featureType == 3 )
{
	return switch ( cardType )
	{
		case	101	:	 1	;
		case	102	:	 1	;
		case	103	:	 6	;
		case	104	:	 1	;
		case	105	:	 1	;
		case	106	:	 1	;
		case	107	:	 1	;
		case	108	:	 2	;
		case	109	:	 1	;
		case	110	:	 3	;
		case	111	:	 2	;
		case	112	:	 4	;
		case	113	:	 1	;
		
		case	151	:	 1	;
		case	152	:	 1	;
		
		case	201	:	 1	;
		
		default: 		 0	;
	}
	return ret;
}

// summonTime
if( featureType == 4 )
{
	var ret = switch( cardType )
	{
		case	101	:	 0.8	;
		case	102	:	 1.0	;
		case	103	:	 1.0	;
		case	104	:	 1.0	;
		case	105	:	 1.2	;
		case	106	:	 1.0	;
		case	107	:	 1.0	;
		case	108	:	 1.0	;
		case	109	:	 1.0	;
		case	110	:	 1.0	;
		case	111	:	 1.0	;
		case	112	:	 0.8	;
		case	113	:	 0.8	;
		
		case	151	:	 2.0	;
		case	152	:	 0.7	;
		
		case	201	:	 0.0	;
		
		default 	: 	 0.0	;
	}
	ret *= 1000;
	return ret;
}

// speed
if( featureType == 11 )
{
	var ret = switch ( cardType )
	{
		case	101	:	0.70;
		case	102	:	0.60;
		case	103	:	1.10;
		case	104	:	1.00;
		case	105	:	0.90;
		case	106	:	0.70;
		case	107	:	1.10;
		case	108	:	1.00;
		case	109	:	0.80;
		case	110	:	1.10;
		case	111	:	1.00;
		case	112	:	0.70;
		case	113	:	0.60;
		
		case	201	:	0.00;
		
		default: 1;
	}
	return ret * 0.085 * 1.3;
}

// health
if( featureType == 12 )
{
	var ret = switch ( cardType )
	{
		case	101	:	0.50;
		case	102	:	5.00;
		case	103	:	0.10;
		case	104	:	1.00;
		case	105	:	1.60;
		case	106	:	0.60;
		case	107	:	0.40;
		case	108	:	1.00;
		case	109	:	0.30;
		case	110	:	0.10;
		case	111	:	1.00;
		case	112	:	1.00;
		case	113	:	1.00;
		
		case	201	:	6.00;
		
		default: 1;
	}
	return (ret + Math.log(cardLevel) * 0.585) * 1.5;
}

// sizeH
if( featureType == 13 )
{
	var ret = return switch ( cardType )
	{
		case	101	:	35	;
		case	102	:	45  ;
		case	103	:	20	;
		case	104	:	35	;
		case	105	:	35	;
		case	106	:	30	;
		case	107	:	45	;
		case	108	:	30	;
		case	109	:	40	;
		case	110	:	25	;
		case	111	:	35	;
		case	112	:	25	;
		case	113	:	25	;
		
		case	201	:	70	;
		
		default: 10;
	}
	
	return ret * 20.00;

}

// sizeV
if( featureType == 14 )
{
	var ret = switch ( cardType )
	{
		case	101	:	0.50;
		case	102	:	0.55;
		case	103	:	0.35;
		case	104	:	0.50;
		case	105	:	0.45;
		case	106	:	0.50;
		case	107	:	0.40;
		case	108	:	0.60;
		case	109	:	1.00;
		case	110	:	0.35;
		case	111	:	0.50;			
		case	112	:	0.50;
		case	113	:	0.50;
		
		case	151	:	1.00;
		
		case	201	:	1.00;
		
		default: 1;
	}
	return ret * 80;
}

// focusRange
if( featureType == 15 )
{
	var ret = switch( cardType )
	{
		case	101	:	1.8 ;
		case	102	:	1.0	;
		case	103	:	0.8	;
		case	104	:	0.8	;
		case	105	:	0.7	;
		case	106	:	1.6	;
		case	107	:	0.7	;
		case	108	:	1.4	;
		case	109	:	1.0	;
		case	110	:	0.8	;
		case	111	:	0.8	;
		case	112	:	0.7 ;
		case	113	:	0.7 ;
		
		case 	201 : 	1.4 ;
		
		default : 1;
	}
	return ret * 350;
}

// explosive
if( featureType == 16 )
{
	return switch ( cardType )
	{
		case	107	:	1;
		default		:	0;
	}
}


// bulletSpeed
if( featureType == 21 )
{
	var ret = switch( cardType )
	{
		case	101	:	3.0	;
		case	102	:	0.7	;
		case	103	:	1.7	;
		case	104	:	1.6	;
		case	105	:	1.0	;
		case	106	:	0.7	;
		case	107	:	0.7	;
		case	108	:	2.0	;
		case	109	:	2.0	;
		case	110	:	1.7	;
		case	111	:	1.6	;
		case	112	:	1.5	;
		case	113	:	1.5	;
		
		case	151	:	1.2 ;
		case	152	:	0.8	;
		
		case	201	:	1.0	;
		
		default : 1;
	}
	return ret * 20.0;
}

// bulletDamage
if( featureType == 22 )
{
	var ret = switch( cardType )
	{
		case	101	:	0.20	;
		case	102	:	0.30	;
		case	103	:	0.10	;
		case	104	:	0.30	;
		case	105	:	0.30	;
		case	106	:	0.25	;
		case	107	:	0.80	;
		case	108	:	0.07	;
		case	109	:  -0.10	; 
		case	110	:  	0.10	;
		case	111	:  	0.30	;
		case	112	:	0.10	;
		case	113	:	0.20	;
		
		case	151	:	1.00	;
		case	152	:	0.60 	;
		
		case	201	:	0.0000000002	;
		
		default : 1;
	}
	var p = ret > 0 ? 1 : -1;
	return ret + (Math.log(cardLevel) * 0.585) * p;
}

// bulletShootGap
if( featureType == 23 )
{
	var ret = switch( cardType )
	{
		case	101	:	2.0 ;
		case	102	:	1.8	;
		case	103	:	0.7	;
		case	104	:	1.6	;
		case	105	:	0.75;
		case	106	:	1.5 ;
		case	107	:	9.0	;
		case	108	:	0.6	;
		case	109	:	1.0	;
		case	110	:	0.7	;
		case	111	:	1.6	;
		case	112	:	0.7	;
		case	113	:	0.8	;
		
		case 	201 :	0.3 ;
		
		default : 1;
	}
	return (ret + Math.log(cardLevel) * 0.585) * 750 ;
}

// bulletShootDelay
if( featureType == 24 )
{
	var ret = switch( cardType )
	{
		case	101	:	0.0	;
		case	102	:	0.7	;
		case	103	:	0.7	;
		case	104	:	0.5	;
		case	105	:	0.0	;
		case	106	:	0.5	;
		case	107	:	0.0	;
		case	108	:	0.0	;
		case	109	:	0.5	;
		case	110	:	0.7	;
		case	111	:	0.5	;
		case	112	:	0.4 ;
		case	113	:	0.4 ;
		
		case	201	:	0.5;
		
		default	: 1;
	}
	return ret * 700 ;
}

// bulletRangeMin
if( featureType == 25 )
{
	return 0;
}

// bulletRangeMax
if( featureType == 26 )
{
	var ret =  switch( cardType )
	{
		case	101	:	1.8 ;
		case	102	:	1.0	;
		case	103	:	0.8	;
		case	104	:	0.8	;
		case	105	:	0.5	;
		case	106	:	1.6	;
		case	107	:	0.1	;
		case	108	:	1.4	;
		case	109	:	1.0	;
		case	110	:	0.8	;
		case	111	:	0.8	;
		case	112	:	0.4 ;
		case	113	:	0.4 ;
		
		case 	201 : 	1.7 ;
		
		default : 1;
	}
	return ret * 300;
}

// bulletDamageArea
if( featureType == 27 )
{
	var ret =  switch( cardType )
	{
		case	101	:	1.00	;
		case	102	:	1.00	;
		case	103	:	1.00	;
		case	104	:	15.0	;
		case	105	:	1.00	;
		case	106	:	18.0	;
		case	107	:	20.0	;
		case	108	:	1.00	;
		case	109	:	12.0	;
		case	110	:	1.00	;
		case	111	:	15.0	;
		case	112	:	1.00	;
		case	113	:	1.00	;
		
		case	151	:	15.0	;
		case	152	:	15.0	;
		
		case 	201 : 	1.00 	;
		
		default 	:	1.00	;
	}
	return ret * 10;
}

// bulletExplodeDelay
if( featureType == 28 )
{
	return switch( cardType )
	{
		case	106	:	200	;
		default		:	0	;
	}
}

return 0;