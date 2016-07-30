//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

@import GoogleMobileAds;

#import <UIKit/UIKit.h>
#import "headers/ALAdService.h"
#import "headers/ALInterstitialAd.h"

@interface AppLovinCustomEventInter : NSObject <GADCustomEventInterstitial, ALAdLoadDelegate, ALAdDisplayDelegate>
@property (strong, atomic) ALAd* appLovinAd;
@end
