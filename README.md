# Map_Transformation

Input - WGS84 (ITRF96 Reference Frame)

Output - HK 1980 Grid Coordinate

WGS84 GPS → 香港 HK1980 方格網坐標

I am looking for some sample code to do this transform, but no one do this (sad).

So I just turn the swift version to Objective C version.

If anyone need swift version, please tell me, I'll upload as well.

在網上找了很久都沒有人用C寫這個GPS的轉換，只好自已來了，希望可以造福大眾。

我也有swift的版本，如果有人需要，請告訴我，我會再上傳 :D

How to use

#import "MapTransformation.h"

In your code :

Coord *mCoord = [gpsTrans toGEOHK:1 phi:[[dictionary objectForKey:@"Latitude"] doubleValue] flam:[[dictionary objectForKey:@"Longitude"] doubleValue]];

NSLog(@"my coord: %f, %f", mCoord.x, mCoord.y);

Finished.
