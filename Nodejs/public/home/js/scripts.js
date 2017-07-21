// JavaScript for themezinho
(function($) {
$(document).ready(function() {
	"use strict";
	
	// FANCYBOX
	/*
		$(".fancybox").fancybox({
		helpers: {
		overlay: {
		  locked: false
			}
		  }
		});
	*/	
		
	// NAVBAR TOGGLE		
		$('.navbar-toggle').on('click', function(e) {
		$(".navbar-toggle").toggleClass("is-active");
		});
		$('body').on('click', function(e) {
		$(".navbar-toggle").removeClass("is-active");
		});
		
		
	// TOOGLE MENU
	//	$('.toggle-menu').jPushMenu({closeOnClickLink: false});
	//	$('.dropdown-toggle').dropdown();
		
		
	// TEXT ROTATE
		var sloganArea = $('.slogan ul');
		sloganArea.width(sloganArea.find('li').eq(0).find('span').width());
	
		setInterval(function () {
			var itemHeight = $('.slogan ul li').eq(0).height();
	
			sloganArea.animate({
				width : $('.slogan ul li').eq(1).find('span').width(),
				top : itemHeight * -1
			},200, function(){
				sloganArea.append($('.slogan ul li').eq(0));
				sloganArea.css('top', 0);
	
				$('.slogan ul li').each(function(i){
					$(this).css('top', i*itemHeight);
				});
			});
	
		}, 2000);
	
	
	// OWL SLIDER		
	/*
		$(".owl-slider").owlCarousel({
			items:1,
			loop:true,
			nav:false,
			dots:true,
			autoplay:true,
			autoplayTimeout:3000,
			autoplayHoverPause:false,
			smartSpeed:450
			
	  	});
		

	// OWL CAROUSEL		
 		$(".owl-carousel").owlCarousel({
			items:4,
			loop:true,
			nav:false,
			dots:true,
			autoplay:true,
			autoplayTimeout:3000,
			autoplayHoverPause:false,
			smartSpeed:450,
			responsive:{
			375:{
				items:2
			},
			768:{
				items:3
			},
			1024:{
				items:4,
			},
			1199:{
				items:4,
			}
		   }
	  	});
		
	
	// OWL SCREENSHOTS	
		$('.owl-screenshots').owlCarousel({
			items:3,
			loop:true,
			center:true,
			nav:false,
			dots:true,
			autoplay:true,
			autoplayTimeout:3000,
			autoplayHoverPause:false,
			smartSpeed:450,
			responsive:{
			375:{
				items:1,
				center: true,
				stagePadding: 25,
				margin:20
			},
			768:{
				items:3,
				center: true,
				stagePadding: 0,
				margin:20
			},
			1024:{
				center: true,
				stagePadding: 0,
				margin:20
			},
			1199:{
				center: true,
				stagePadding: 100,
				margin:30
			}
		   }
		});
	*/
		
		
	// GO TO TOP
		$(window).scroll(function () {
			if ($(this).scrollTop() > 100) {
				$('.scrollup').fadeIn();
			} else {
				$('.scrollup').fadeOut();
			}
    	});

    	$('.scrollup').click(function () {
			$("html, body").animate({
				scrollTop: 0
			}, 600);
			return false;
    	});

	
	
});

	// COUNTER EFFECT
		var n = document.getElementById("counter");
			if (n == null) {
		} 
		else {
		
		var lastWasLower = false;
			$(document).scroll(function(){
			
			var p = $( "#counter" );
			var position = p.position();
			var position2 = position.top;
		
			if ($(document).scrollTop() > position2-300){
			if (!lastWasLower)
				$('#1').html('93');
				$('#2').html('7305');
				$('#3').html('23');
		
			lastWasLower = true;
				} else {
			lastWasLower = false;
			}
			});		
		};
		

	// WOW ANIMATION
		wow = new WOW(
      	{
       		animateClass: 'animated',
        	offset:       50
      	}
    	);
    	wow.init();
		
})(jQuery);