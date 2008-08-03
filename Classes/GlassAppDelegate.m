//
//  GlassAppDelegate.m
//  Glass
//
//  Created by Eric Oesterle on 8/2/08.
//  Copyright InPlace 2008. All rights reserved.
//

#import "GlassAppDelegate.h"
#import "GlassViewController.h"

@implementation GlassAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize	passPersonalInfo;
@synthesize passGeoData;

@synthesize lastKnownLocation;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	locationManager = [[CLLocationManager alloc] init];
	locationManager.delegate = self;
	[locationManager startUpdatingLocation];
	
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:1.0/40.0];
	[[UIAccelerometer sharedAccelerometer] setDelegate:self];
	
	// Override point for customization after app launch	
    [window addSubview:viewController.view];
	webView.delegate = self;
	// [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://google.com"]]];
	
	
	NSString * htmlFileName;
	NSString * urlFileName;
	
	htmlFileName = @"index";
	urlFileName = @"url";
	
	// NSString * htmlPathString = [[NSBundle mainBundle] resourcePath];
	NSString * urlPathString; //= [[NSBundle mainBundle] resourcePath];
	
	NSBundle * thisBundle = [NSBundle bundleForClass:[self class]];
	
	/*
	 if (htmlPathString = [thisBundle pathForResource:htmlFileName ofType:@"html"]) {
		NSURL * anURL = [NSURL fileURLWithPath:htmlPathString];
		NSURLRequest * aRequest = [NSURLRequest requestWithURL:anURL];
		
	 }
	 */
	
	if (urlPathString = [thisBundle pathForResource:urlFileName	ofType:@"txt"]){
		NSString * theURLString = [NSString stringWithContentsOfFile:urlPathString];
		NSURL * anURL = [NSURL URLWithString:theURLString];
		NSURLRequest * aRequest = [NSURLRequest requestWithURL:anURL];
		
		[webView loadRequest:aRequest];
	}
	
	[window makeKeyAndVisible];
}

- (BOOL)webView:(UIWebView *)webView2 shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	NSString * myURL = [[request URL] absoluteString];
	NSLog(myURL);
	NSString * jsCallBack = nil;
	NSArray * parts = [myURL componentsSeparatedByString:@":"];
	printf("XX");
	NSLog([self.lastKnownLocation description]);
	printf("XX");
	double lat = lastKnownLocation.coordinate.latitude;
	double lon = lastKnownLocation.coordinate.longitude;
	
	if (2 == [parts count]){
		NSLog([parts objectAtIndex:0]);
		NSLog([parts objectAtIndex:1]);
		
		if ([(NSString *)[parts objectAtIndex:0] isEqualToString:@"gap"]){
			if([(NSString *)[parts objectAtIndex:1] isEqualToString:@"getloc"]){
				NSLog(@"location request!");
				
				jsCallBack = [[NSString alloc] initWithFormat:@"gotLocation('%f','%f');", lat, lon];
				[webView2 stringByEvaluatingJavaScriptFromString:jsCallBack];
				
				[jsCallBack release];
			}
			
			return NO;
		}
			
	}
	
	return YES;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	[lastKnownLocation release];
	lastKnownLocation = newLocation;
	[lastKnownLocation retain];
	printf("Updating Location to : %s",[[lastKnownLocation description] UTF8String]);	
	
	double lat = lastKnownLocation.coordinate.latitude;
	double lng = lastKnownLocation.coordinate.longitude;
	
	passPersonalInfo = YES;
	passGeoData = YES;
	
	//This is how you do it with a GET
	NSString *urlTemp = nil;
	//NSString *personalInfoTemp = @"?personalInfo=BrockWhitten";
	//NSString *geoDataTemp = [[NSString alloc] initWithFormat:@"&geoData=%@", @"foo" ];
	NSString *latTemp = [[NSString alloc] initWithFormat:@"lat=%f", lat ];
	NSString *lngTemp = [[NSString alloc] initWithFormat:@"&long=%f", lng ];
	urlTemp = [[NSString alloc] initWithFormat:@"http://clayburn.org/iphone.php?%@%@", latTemp, lngTemp];
	
	//[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlTemp]];
	
}

- (void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
	NSString * jsCallBack = nil;
	
	jsCallBack = [[NSString alloc] initWithFormat:@"gotAcceleration('%f','%f','%f');", acceleration.x, acceleration.y, acceleration.z];
	NSLog(jsCallBack);
	
	NSString * ret = [webView stringByEvaluatingJavaScriptFromString:jsCallBack];
	NSLog(ret);
}



- (void)dealloc {
    [viewController release];
	[window release];
	[lastKnownLocation release];
	[super dealloc];
}


@end
