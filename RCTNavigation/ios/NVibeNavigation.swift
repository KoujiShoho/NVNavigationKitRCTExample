import Foundation
import React
import CoreLocation
import NVDirectionKit
import NVNavigationKit
//import NVIndoorKit

@objc(NVibeNavigation)
class NVibeNavigation: RCTEventEmitter {
    private var navigationService: NVNavigationService? = nil
    private var index: Int = 0

    override init() {
        super.init()
        //RNEventEmitter.emitter = self
        navigationService = NVNavigationService(delegate: self)
    }
    
    override class func requiresMainQueueSetup() -> Bool {
        return false
    }

    open override func supportedEvents() -> [String] {
        ["onWalkingNavigationStarted", "onTest", "onTokenError"]
    }
    
    @objc
    func test(_ value: NSDictionary) {
        guard let result = value as? [String: Any] else {
            print("cast not working")
            return
        }
        print("test \(value)")
        self.index += 1
        self.sendEvent(withName: "onTest", body: [self.index])
    }
    
    @objc
    func getData(_ value: NSDictionary) {
        guard let result = value as? [String: Any] else {
            print("cast not working")
            return
        }
        print("test \(value)")
        self.index += 1
        self.sendEvent(withName: "onData", body: [self.index])
    }
    
    @objc
    func getRoute(_ origin: NSDictionary, destination: NSDictionary, callback: @escaping RCTResponseSenderBlock) {
        guard let origin = origin as? [String: Any] else {
            print("cast not working")
            return
        }
        
        guard let destination = destination as? [String: Any] else {
            print("cast not working")
            return
        }
        
        if let originLocation = origin["position"] as? [String: Any], let destinationLocation = destination["position"] as? [String: Any] {
            let startLocation = NVibeLocation(position: CLLocationCoordinate2D(latitude: originLocation["latitude"] as! Double, longitude: originLocation["longitude"] as! Double))
            let endLocation = NVibeLocation(position: CLLocationCoordinate2D(latitude: destinationLocation["latitude"] as! Double, longitude: destinationLocation["longitude"] as! Double))
            
            NVDirection.shared.getNavigationRoute(from: startLocation, to: endLocation, sideStreet: .RIGHT) { [weak self] (result, error) in
                guard let self else {
                    print("self error")
                    callback(["self error", NSNull()])
                    return
                }
                
                guard let result = result else {
                    print("onNavigationRouteRecuperationFailed")
                    callback(["no route error", NSNull()])
                    return
                }
                
                print("onNavigationRouteRecuperationSuccessed")
                callback([NSNull(), result.route.geometry])
            }
        }
    }
    
    @objc
    func startNavigation(_ origin: NSDictionary, destination: NSDictionary) {
        print("startNavigation")
        guard let origin = origin as? [String: Any] else {
            print("cast not working")
            return
        }
        
        guard let destination = destination as? [String: Any] else {
            print("cast not working")
            return
        }
        
        if let originLocation = origin["position"] as? [String: Any], let destinationLocation = destination["position"] as? [String: Any] {
            let startLocation = NVibeLocation(position: CLLocationCoordinate2D(latitude: originLocation["latitude"] as! Double, longitude: originLocation["longitude"] as! Double))
            let endLocation = NVibeLocation(position: CLLocationCoordinate2D(latitude: destinationLocation["latitude"] as! Double, longitude: destinationLocation["longitude"] as! Double))
            
            NVDirection.shared.getNavigationRoute(from: startLocation, to: endLocation, sideStreet: .RIGHT) { [weak self] (result, error) in
                guard let self else {
                    print("self error")
                    return
                }
                
                guard let result = result else {
                    print("onNavigationRouteRecuperationFailed")
                    return
                }
                
                print("onNavigationRouteRecuperationSuccessed")
                
                self.navigationService?.startNavigation(route: result.route)
            }
            return
        }
        print("Error in NSDictionary")
    }
    
    @objc
    func stopNavigation() {
        print("stopNavigation")
        self.navigationService?.stopNavigation()
    }
}

extension NVibeNavigation: NVNavigationServiceDelegate {
    func navigationService(_ service: NVNavigationKit.NVNavigationService, didStartWith step: NVDirectionKit.NVibeStep, atRemaining routeDistance: CLLocationDistance, atRemaining stepDistance: CLLocationDistance, withRemaining routeDuration: Double, with image: NVNavigationKit.ImageType) {
        print("onWalkingNavigationStarted")
        self.sendEvent(withName: "onWalkingNavigationStarted", body: [])
    }
    
    func navigationService(_ service: NVNavigationKit.NVNavigationService, didUpdate progress: NVNavigationKit.NVibeRouteProgress, with rawLocation: CLLocation, snappedTo location: CLLocation) {
        print("onWalkingNavigationUpdated")
    }
    
    func navigationService(_ service: NVNavigationKit.NVNavigationService, didStopWith instruction: String, with image: NVNavigationKit.ImageType) {
        print("onWalkingNavigationStopped")
    }
    
    func navigationService(_ service: NVNavigationKit.NVNavigationService, shouldRerouteFrom location: CLLocation) -> Bool {
        return true
    }
    
    func navigationService(_ service: NVNavigationKit.NVNavigationService, didRerouteAlong route: NVDirectionKit.NVibeRoute, to direction: CLLocationDirection, with step: NVDirectionKit.NVibeStep, atRemaining routeDistance: CLLocationDistance, atRemaining stepDistance: CLLocationDistance, withRemaining routeDuration: Double, with image: NVNavigationKit.ImageType) {
        print("onWalkingNavigationRerouted")
    }
    
    func navigationService(_ service: NVNavigationKit.NVNavigationService, didUpdateUIWith step: NVDirectionKit.NVibeStep, atRemaining routeDistance: CLLocationDistance, atRemaining stepDistance: CLLocationDistance, with image: NVNavigationKit.ImageType) {
        print("onUpdateUI")
    }
    
    func navigationService(_ service: NVNavigationKit.NVNavigationService, didUpdateRightDirectionWith vibration: NVDirectionKit.NVibeVibration) {
        print("=======================> onRightDirectionUpdate : \(vibration)")
    }
    
    func navigationService(_ service: NVNavigationKit.NVNavigationService, willChange step: NVDirectionKit.NVibeStep, with vibration: NVDirectionKit.NVibeVibration, atRemaining stepDistance: CLLocationDistance) {
        print("=======================> onPrepareToChangeStep : \(step.maneuver.instruction) dans \(stepDistance)\nvibration : \(vibration)")
    }
    
    func navigationService(_ service: NVNavigationKit.NVNavigationService, didChange step: NVDirectionKit.NVibeStep, with vibration: [NVDirectionKit.NVibeVibration]) {
        print("=======================> onChangeStep : \(step.maneuver.instruction)\nvibration : \(vibration)")
    }
    
    func navigationService(_ service: NVNavigationKit.NVNavigationService, didForceChangeSideFor step: NVDirectionKit.NVibeStep, atRemaining stepDistance: CLLocationDistance, with vibration: NVDirectionKit.NVibeVibration) {
        if step.maneuver.type != "arrive" {
            print("=======================> onForceChangeSideStreetOccured : préparez-vous à \(step.maneuver.instruction) dans \(stepDistance)\nvibration : \(vibration)")
        }
    }
    
    func navigationService(_ service: NVNavigationKit.NVNavigationService, didPauseNavigationOnBadAccuracy: Bool) {
        print("=======================> onAccuracyUpdated : \(didPauseNavigationOnBadAccuracy)")
    }
    
    func navigationService(_ service: NVNavigationKit.NVNavigationService, didFailToPassTokenWith error: NVDirectionKit.TokenError) {
        switch error {
        case .INVALID_TOKEN:
            print("INVALID_TOKEN")
            self.sendEvent(withName: "onTokenError", body: [])
        case .MAX_ACTIVE_USER_REACHED:
            print("MAX_ACTIVE_USER_REACHED")
            self.sendEvent(withName: "onTokenError", body: [])
        default:
            print("UNKNOW")
            self.sendEvent(withName: "onTokenError", body: [])
        }
    }
}
