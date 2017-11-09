//
//  MapTransformation.m
//  DramisMobileApp
//
//  Created by shiusimpletonyoyo on 08/11/2017.
//  Copyright © 2017 dsd. All rights reserved.
//

#import "MapTransformation.h"
#import "RadiusData.h"

static double pi = 3.14159265359;

@implementation MapTransformation
- (Coord *) toGEOHK:(double)IG phi:(double)PHI flam:(double)FLAM{
    
    NSLog(@"mCoord :%f, %F", PHI, FLAM);
    //**** CONVERT GEODETIC COORDINTES TO HK METRIC GRID COORDINATES
    // ENTRY:
    //         IG   ; 1 FOR HAYFORD SPHEROID, 2 FOR WG282 SPHEROID
    //         PHI  : LATITUDE   IN DECIMAL DEGREES
    //         FLAM : LONGITUDE  IN DECIMAL DEGREES
    // RETURN :
    //         X    :  NORTHING  (HK 1980 METRIC DATAM)
    //         Y    :  EASTING
    
    double RAD, PHI0, FLAM0, RPHI;
    double RLAM, SM0, SM1, CJ;
    double TPHI, TPHI2, TPHI4, TPHI6;
    double TT, TT2, TT3, TT4;
    double XF, X1, X2, X3, X4;
    double YF, Y1, Y2, Y3;
    double WX, WY, a, b, C, D;
    double RHO, RMU;
    double X, Y;
    //    var RAD: Double, PHI0: Double, FLAM0: Double, RPHI: Double;
    //    var RLAM: Double, SM0: Double, SM1: Double, CJ: Double;
    //    var TPHI: Double, TPHI2: Double, TPHI4: Double, TPHI6: Double;
    //    var TT: Double, TT2: Double, TT3: Double, TT4: Double;
    //    var XF: Double, X1: Double, X2: Double, X3: Double, X4: Double;
    //    var YF: Double, Y1: Double, Y2: Double, Y3: Double;
    //    var WX: Double, WY: Double, a: Double, b: Double, C: Double, D: Double;
    //    var RHO: Double, RMU: Double;
    //    var X: Double, Y: Double;
    
    Coord *result = [[Coord alloc] init];
    RadiusData *RadiusResult = [[RadiusData alloc] init];
    
    RAD = pi / 180.0;
    
    //--- CONVERT PROJECTION ORIGIN TO RADIANS
    if (IG == 1)
    {
        NSLog(@"GPS.IG = 1");
        PHI0 = (22.0 + 18.0 / 60.0 + 43.68 / 3600.0) * RAD;
        FLAM0 = (114.0 + 10.0 / 60.0 + 42.8 / 3600.0) * RAD;
    }
    else
    {
        PHI0 = (22.0 + 18.0 / 60.0 + 38.17 / 3600.0) * RAD;
        FLAM0 = (114.0 + 10.0 / 60.0 + 51.65 / 3600.0) * RAD;
    }
    
    //--- CONVERT LATITUDE AND LONGITUDE TO RADIANS
    
    RPHI = PHI * RAD;
    RLAM = FLAM * RAD;
    
    //--- COMPUTE MERIDIAN ARCS
    SM0 = [self SMER:IG phi0:0 phif:PHI0];
    SM1 = [self SMER:IG phi0:0 phif:RPHI];
//    SM0 = SMER(IG, PHI0: 0, PHIF: PHI0);
//    SM1 = SMER(IG, PHI0: 0, PHIF: RPHI);
    
    //--- COMPUTE RADII
    RadiusResult = [self RADIUS:IG phi:RPHI];
//    RadiusResult = RADIUS(IG, PHI: RPHI);
    RHO = RadiusResult.rho;
    RMU = RadiusResult.rmu;
    
    //--- COMPUTE CJ (IN RADIANS)
    CJ = (RLAM - FLAM0) * cos(RPHI);
    TPHI = tan(RPHI);
    TPHI2 = TPHI * TPHI;
    TPHI4 = TPHI2 * TPHI2;
    TPHI6 = TPHI2 * TPHI4;
    TT = RMU / RHO;
    TT2 = pow(TT,2);
    TT3 = pow(TT,3);
    TT4 = pow(TT,4);
    
    //--- COMPUTE  NORTHING
    XF = SM1 - SM0;
    X1 = RMU / 2.0 * pow(CJ,2) * TPHI;
    X2 = X1 / 12.0 * pow(CJ,2) * (4.0 * TT2 + TT - TPHI2);
    X3 = X2 / 30.0 * pow(CJ,2) * (8.0 * TT4 * (11.0 - 24.0 * TPHI2) - 28.0 * TT3 * (1.0 - 6.0 * TPHI2) + TT2 * (1.0 - 32.0 * TPHI2) - 2 * TT * TPHI2 + TPHI4);
    X4 = X3 / 56.0 * pow(CJ,2) * (1385.0 - 3111.0 * TPHI2 + 543.0 * TPHI4 - TPHI6);
    X = XF + X1 + X2 + X3 + X4 + 819069.8;
    
    //--- COMPUTE  EASTING
    YF = RMU * CJ;
    Y1 = YF / 6.0 * pow(CJ,2);
    Y2 = Y1 / 20.0 * pow(CJ,2);
    Y3 = Y2 / 42.0 * pow(CJ,2);
    Y1 = Y1 * (TT - TPHI2);
    Y2 = Y2 * (4.0 * TT3 * (1.0 - 6.0 * TPHI2) + TT2 * (1.0 + 8.0 * TPHI2) - TT * 2.0 * TPHI2 + TPHI4);
    Y3 = Y3 * (61.0 - 479.0 * TPHI2 + 179.0 * TPHI4 - TPHI6);
    Y = YF + Y1 + Y2 + Y3 + 836694.05;
    
    if (IG == 2)
    {
        WX = X;
        WY = Y;
        
        //---   TRANSFROM WGS84 GRID TO HK 1980 GRID
        a = 0.9999998373;
        b = -0.000027858;
        C = -23.098331;
        D = 23.149765;
        X = a * WX - b * WY + C;
        Y = b * WX + a * WY + D;
    }
    
    result.x = X;
    result.y = Y;
    return result;
} // --- GEOHK

- (double)SMER:(double)IG phi0: (double)PHI0 phif:(double)PHIF{
    
    //**** COMPUTE MERIDIAN ARC
    // ENTRY:
    //         PHI0 : LATITUDE OF ORIGIN
    //         PHIF : LATITUDE OF PROJECTION TO CENTRAL MERIDIAN
    // RETURN :
    //         SMER : MERIDIAN ARC
    
    double AXISM, FLAT, ECC;
    double a, b, C, D, DP0;
    double DPO, DP2;
    double DP4, DP6;
    double SMER;
//    var AXISM: Double, FLAT: Double, ECC: Double;
//    var a: Double, b: Double, C: Double, D: Double, DP0: Double;
//    var DPO: Double, DP2: Double;
//    var DP4: Double, DP6: Double;
//    var SMER: Double;
    
    if (IG == 1) {
        AXISM = 6378388.0;
        FLAT = 1.0 / 297.0;
    }
    else {
        AXISM = 6378137.0;
        FLAT = 1.0 / 298.2572235634;
    }
    
    ECC = 2 * FLAT - pow(FLAT,2);
    ECC = sqrt(ECC);
    a = 1 + 3.0 / 4.0 * pow(ECC,2) + 45.0 / 64.0 * pow(ECC,4) + 175.0 / 256.0 * pow(ECC,6);
    b = 3.0 / 4.0 * pow(ECC,2) + 15.0 / 16.0 * pow(ECC,4) + 525.0 / 512.0 * pow(ECC,6);
    C = 15.0 / 64.0 * pow(ECC,4) + 105.0 / 256.0 * pow(ECC,6);
    D = 35.0 / 512.0 * pow(ECC,6);
    DP0 = PHIF - PHI0;
    DP2 = sin(2.0 * PHIF) - sin(2.0 * PHI0);
    DP4 = sin(4.0 * PHIF) - sin(4.0 * PHI0);
    DP6 = sin(6.0 * PHIF) - sin(6.0 * PHI0);
    SMER = AXISM * (1 - pow(ECC,2));
    SMER = SMER * (a * DP0 - b * DP2 / 2.0 + C * DP4 / 4.0 - D * DP6 / 6.0);
    
    return SMER;
} // --- SMER

- (RadiusData *)RADIUS:(double)IG phi: (double)PHI{
    
    //**** COMPUTE RADII OF CURVATURE OF A GIVEN LATITUDE
    // ENTRY:
    //         PHI  : LATITUDE
    // RETURN:
    //         RHO  : RADIUS OF MERIDIAN
    //         PMU  : RADIUS OF PRIME VERTICAL
    
    double AXISM, FLAT, ECC;
    double FAC;
    double RHO, RMU;
//    var AXISM: Double, FLAT: Double, ECC: Double;
//    var FAC: Double;
//    var RHO: Double, RMU: Double;
    
    RadiusData *RadiusResult = [[RadiusData alloc] init];
//    var RadiusResult = RadiusData.init(rho: 0.0, rmu: 0.0);
    
    if (IG == 1) {
        AXISM = 6378388.0;
        FLAT = 1.0 / 297.0;
    }
    else {
        AXISM = 6378137.0;
        FLAT = 1.0 / 298.2572235634;
    }
    ECC = 2.0 * FLAT - pow(FLAT,2);
    FAC = 1.0 - ECC * (pow(sin(PHI),2));
    RHO = AXISM * (1 - ECC) / pow(FAC,1.5);
    RMU = AXISM / sqrt(FAC);
    
    RadiusResult.rho = RHO;
    RadiusResult.rmu = RMU;
    return RadiusResult;
} // --- Radius
@end
