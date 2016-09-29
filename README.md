# deferred-location-implementation
Proof of concept app for DLU


Area:
CoreLocation (Location Services)

# Summary:
Deferred location updates immediately errors out with kCLErrorDeferredFailed (error code 11). Even after repeated retry (I use the prototype app for several hours), DLU does not kick in. 

The behavior was different on iOS 9.3.5 and DLU kicked in as/when expected.

# Steps to Reproduce:
I created a proof of concept app. Source code at: https://github.com/zakishaheen/deferred-location-implementation

It simply seeks always access and then starts location updating. Upon going to background, I restart the location service and on next location update, it will attempt to allow DLU. On iOS 9, it eventually succeeds (in my tests, after about 5 minutes) but on iOS 10 it keeps failing. 

# Expected Results:
Even though the documentation is fairly vague on why DLU might fail, I ensured that no other app is interfering and I expect it to eventually succeed (preferably deterministically) on iOS 10 (as it did on iOS 9). 

# Actual Results:
DLU keeps failing on iOS 10.0.1.

# Version:
iOS 10.0.1

# Notes:
I have tested the same code on iPhone 5S running iOS 9.3.5 and at the same time iPhone 6S+ with iOS 10.0.1 (GM seed). Both of phones were in my pocket as I took a walk around the block. It was ensured that no other app is using background location. 

# Configuration:
iPhone 5S (iOS 9.3.5), iPhone 6S+ (iOS 9.3.5) and iPhone 6S+ (iOS 10.0.1)
