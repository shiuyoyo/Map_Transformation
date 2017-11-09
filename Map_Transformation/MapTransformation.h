//
//  MapTransformation.h
//  DramisMobileApp
//
//  Created by shiusimpletonyoyo on 08/11/2017.
//  Copyright © 2017 dsd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Coord.h"

@interface MapTransformation : NSObject
- (Coord *) toGEOHK:(double) IG phi:(double)PHI flam:(double)FLAM;
@end
