//
//  Health.swift
//  Health
//
//  Created by Andreas on 8/17/21.
//

import SwiftUI
import HealthKit
import NiceNotifications
import Combine
import HKCombine

class Health: ObservableObject {
    @Published var codableRisk = [CodableRisk(id: UUID().uuidString, date: Date(), risk: 0.0, explanation: [String]())]
    @Published var healthStore = HKHealthStore()
    @Published var risk = Risk(id: "", risk: 21, explanation: [Explanation(image: .exclamationmarkCircle, explanation: "Explain it here!!"), Explanation(image: .questionmarkCircle, explanation: "Explain it here?"), Explanation(image: .circle, explanation: "Explain it here.")])
//    @Published var readData: [HKQuantityTypeIdentifier] =  [.heartRateVariabilitySDNN,
//                                                            .restingHeartRate,
//                                                            .walkingHeartRateAverage,
//                                                            .heartRate,
//                                                            .walkingSpeed,
//                                                            .respiratoryRate, .oxygenSaturation]
    @Published var readData: [HKQuantityTypeIdentifier] =  [.stepCount, .respiratoryRate, .oxygenSaturation]//, .stepCount]
    @Published var healthData = [HealthData]()
    @Published var tempHealthData = HealthData(id: UUID().uuidString, type: .Feeling, title: "", text: "", date: Date(), data: 0.0)
    @Published var healthChartData = ChartData(values: [("", 0.0)])
    @Published var todayHeartRate = [HealthData]()
    @State var onboarding = UserDefaults.standard.bool(forKey: "onboarding")
    init() {
       
            self.backgroundDelivery()
//        let earlyDate = Calendar.current.date(
//          byAdding: .day,
//          value: -30,
//          to: Date())
//        self.getActiveEnergyHealthData(startDate: earlyDate ?? Date(), endDate: Date())
//        self.getHeartRateHealthData(startDate: earlyDate ?? Date(), endDate: Date())
        
    }
    func backgroundDelivery() {
        let readType2 = HKObjectType.quantityType(forIdentifier: .heartRate)
       
        healthStore.enableBackgroundDelivery(for: readType2!, frequency: .immediate) { success, error in
            if !success {
                print("Error enabling background delivery for type \(readType2!.identifier): \(error.debugDescription)")
            } else {
                print("Success enabling background delivery for type \(readType2!.identifier)")
               // self.retrieveSleepAnalysis() { sleep in
                    //let sleepingHours = sleep.map{$0.date.get(.hour)}
                   
                        //self.getHealthData(type: .heartRate, dateDistanceType: .Week, dateDistance: self.onboarding ? 7 : 30, endDate: Date()) { value in
                let earlyDate = Calendar.current.date(
                  byAdding: .day,
                  value: -30,
                  to: Date())
                print(earlyDate)
                    //for type in self.readData {
                //self.startHeartRateQuery(quantityTypeIdentifier: .activeEnergyBurned)
                    self.getActiveEnergyHealthData(startDate: earlyDate ?? Date(), endDate: Date())
                //self.getHeartRateHealthData(startDate: earlyDate ?? Date(), endDate:   Date())
//                    print(data)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                for data in self.healthData {
                   print(data)
//
                    let earlyDate = Calendar.current.date(
                      byAdding: .hour,
                      value: -1,
                      to: data.date)
                    let lateDate = Calendar.current.date(
                      byAdding: .hour,
                      value: 1,
                      to: data.date)
                    print(earlyDate)
                    print(lateDate)
                    self.getHeartRateHealthData(startDate: earlyDate ?? Date(), endDate:  lateDate ?? Date())
//                    print(data)
                }
               }
               
                    //}
               // self.getHealthData(type: .heartRate, dateDistanceType: .Month, dateDistance: self.onboarding ? 24 : 24, endDate: Date()) { [self] value in
//                            let filtered = self.codableRisk.filter {
//                                return $0.risk > 0
//                            }
//                            print(filtered)
                           
                            //let riskScore = self.getRiskScore(bedTime: sleepingHours.max() ?? 0, wakeUpTime: sleepingHours.min() ?? 0, data: value).0.risk
                            
//                            let riskScore = self.getRiskScore(bedTime: 0, wakeUpTime: 4, data: value).0.risk
//                    print()
//                            if  riskScore > 0.5 && riskScore != 21.0 {
////                                print("RISK DAYS")
////                                print(codableRisk[codableRisk.count - 2].date.get(.day) + 1)
////                                print(codableRisk.last?.date.get(.day))
//                                if self.codableRisk.indices.contains(codableRisk.count - 2) {
//                                    if (codableRisk[codableRisk.count - 2]).risk > 0.5 {
//                                        if codableRisk[codableRisk.count - 2].date.get(.day) + 1 == codableRisk.last?.date.get(.day) ?? 0 {
//
//
//
//                                LocalNotifications.schedule(permissionStrategy: .askSystemPermissionIfNeeded) {
//                                    Today()
//                                        .at(hour: Date().get(.hour), minute: Date().get(.minute) + 1)
//                                        .schedule(title: "Significant Risk", body: "Your health data may indicate that you may be becoming sick")
//                                }
//                                }
//
//                                }
//        //            print(self.average(numbers: self.codableRisk.map{$0.risk}))
//                //}
//                            }
//            }
                    if self.healthData.isEmpty {
                        
                    } else {
                        
                       // }

            }
                  //  }
                    }
                }
           
            
           
    }
    var cancellableBag = Set<AnyCancellable>()
    var cancellableBag2 = Set<AnyCancellable>()
    //@Published var pubHealth: AnyPublisher<HealthData?, Never>
    func getActiveEnergyHealthData(startDate: Date, endDate: Date) {
       
        healthStore
            .get(sample: HKSampleType.quantityType(forIdentifier: .activeEnergyBurned)!, start: startDate, end: endDate)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { subscription in
                print(1)
            }, receiveValue: { samples in
               print(2)
                for sample in samples {
                    print(sample)
                    //data.append(sample.quantity.is(compatibleWith: .percent()) ? sample.quantity.doubleValue(for: .percent()) : sample.quantity.is(compatibleWith: .count()) ? sample.quantity.doubleValue(for: .count()) : sample.quantity.is(compatibleWith: .inch()) ? sample.quantity.doubleValue(for: .inch()) : sample.quantity.is(compatibleWith: HKUnit.count().unitDivided(by: HKUnit.minute())) ? sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute())) : sample.quantity.is(compatibleWith: .largeCalorie()) ? sample.quantity.doubleValue(for: .largeCalorie()) : sample.quantity.doubleValue(for: HKUnit.mile().unitDivided(by: HKUnit.hour())))
                    print(sample.startDate)
                    print(sample.endDate)
                    self.healthData.append(HealthData(id: UUID().uuidString, type: .Health, title: HKSampleType.quantityType(forIdentifier: .activeEnergyBurned)?.identifier ?? "", text: "", date: sample.startDate, data: sample.endDate.timeIntervalSince1970))
                    print(self.healthData)
                }
                
            }).store(in: &cancellableBag)
    }
    func getHeartRateHealthData(startDate: Date, endDate: Date) {
       
       
        healthStore
            .get(sample: HKSampleType.quantityType(forIdentifier: .heartRate)!, start: startDate, end: endDate)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { subscription in
                print(1)
            }, receiveValue: { samples in
               print(2)
                for sample in samples {
                    print(sample)
                    //data.append(sample.quantity.is(compatibleWith: .percent()) ? sample.quantity.doubleValue(for: .percent()) : sample.quantity.is(compatibleWith: .count()) ? sample.quantity.doubleValue(for: .count()) : sample.quantity.is(compatibleWith: .inch()) ? sample.quantity.doubleValue(for: .inch()) : sample.quantity.is(compatibleWith: HKUnit.count().unitDivided(by: HKUnit.minute())) ? sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute())) : sample.quantity.is(compatibleWith: .largeCalorie()) ? sample.quantity.doubleValue(for: .largeCalorie()) : sample.quantity.doubleValue(for: HKUnit.mile().unitDivided(by: HKUnit.hour())))
                    print(sample.startDate)
                    print(sample.endDate)
                    self.healthData.append(HealthData(id: UUID().uuidString, type: .Health, title: HKSampleType.quantityType(forIdentifier: .heartRate)?.identifier ?? "", text: "", date: sample.startDate, data: sample.quantity.doubleValue(for: self.heartrateQuantity)))
                    print(self.healthData)
                }
                
                
            }).store(in: &cancellableBag2)
    }
    @Published var heathDataTmp = HealthData(id: "", type: .Health, title: "", text: "", date: Date(), data: 0.0)
//    func getHeartRateHealthData(startDate: Date, endDate: Date) {
//      healthStore
//            .statistic(for: HKObjectType.quantityType(forIdentifier: .heartRate)!, with: .discreteAverage, from: startDate, to: endDate)
//            .map({HealthData(id: UUID().uuidString, type: .Health, title: HKObjectType.quantityType(forIdentifier: .heartRate)!.identifier, text: "", date: startDate, data: $0.averageQuantity()?.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute())) ?? 0.0)  })
//            .replaceError(with: tempHealthData)
//            .assertNoFailure()
//            .sink(receiveCompletion: { subscription in
//                /// Do something at the subscriber's end of life or error
//                 print(1)
//            }, receiveValue: { samples in
//                self.healthData.append(samples)
//
//            }).store(in: &cancellableBag)
//
//            //.assign(to: \.heathDataTmp, on: self)
//
//
//    }
    private func startHeartRateQuery(quantityTypeIdentifier: HKQuantityTypeIdentifier) {
            
            // 1
            let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
            // 2
            let updateHandler: (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void = {
                query, samples, deletedObjects, queryAnchor, error in
                
                // 3
            guard let samples = samples as? [HKQuantitySample] else {
                return
            }
                
            self.process(samples, type: quantityTypeIdentifier)

            }
            
            // 4
            let query = HKAnchoredObjectQuery(type: HKObjectType.quantityType(forIdentifier: quantityTypeIdentifier)!, predicate: devicePredicate, anchor: nil, limit: HKObjectQueryNoLimit, resultsHandler: updateHandler)
            
            query.updateHandler = updateHandler
            
            // 5
            
            healthStore.execute(query)
        }
    let calorieQuantity = HKUnit(from: .calorie)
    let heartrateQuantity = HKUnit(from: "count/min")
        private func process(_ samples: [HKQuantitySample], type: HKQuantityTypeIdentifier) {
            
            
            for sample in samples {
                //if type == .activeEnergyBurned {
                    healthData.append(HealthData(id: UUID().uuidString, type: .Health, title: type.rawValue, text: "", date: sample.startDate, data: sample.quantity.doubleValue(for: calorieQuantity)))
                    print(sample)
               // }
                
               
            }
        }
    func average(numbers: [Double]) -> Double {
       // print(numbers)
       return Double(numbers.reduce(0,+))/Double(numbers.count)
   }
    func convertHealthDataToChart(healthData: [HealthData], completionHandler: @escaping (ChartData) -> Void) {
        
        for data in healthData {
            healthChartData.points.append((data.type.rawValue,  data.data*10))
            
        }
        completionHandler(healthChartData)
    }
    func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        
        // just send back the first one, which ought to be the only one
        return paths[0]
    }
}

