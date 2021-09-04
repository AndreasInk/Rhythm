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
    @State var medianOfAverages = UserDefaults.standard.double(forKey: "medianOfAverages")
    init() {
        //DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//        if medianOfAverages == 0 {
//            syncAllData()
//        } else {
        backgroundDelivery()
       // }
       // }
           
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
                  value: -4,
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
                      byAdding: .minute,
                      value: -30,
                      to: data.date)
                    let lateDate = Calendar.current.date(
                      byAdding: .minute,
                      value: 30,
                      to: data.date)
                    print(earlyDate)
                    print(lateDate)
                    self.getHeartRateHealthData(startDate: earlyDate ?? Date(), endDate:  lateDate ?? Date())
//                    print(data)
                }
               
               
                    //}
               // self.getHealthData(type: .heartRate, dateDistanceType: .Month, dateDistance: self.onboarding ? 24 : 24, endDate: Date()) { [self] value in
//                            let filtered = self.codableRisk.filter {
//                                return $0.risk > 0
//                            }
//                            print(filtered)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
              //  let riskScore = self.getRiskScoreAll(bedTime: 0, wakeUpTime: 24, data: self.healthData).0.risk
                        self.getRiskScorev2()
//                let riskScore = self.getRiskScore(bedTime: 0, wakeUpTime: 4, data: self.healthData).0.risk
                    
//                            if  riskScore > 0.5 && riskScore != 21.0 {
////                                print("RISK DAYS")
////                                print(codableRisk[codableRisk.count - 2].date.get(.day) + 1)
////                                print(codableRisk.last?.date.get(.day))
//                                if self.codableRisk.indices.contains(self.codableRisk.count - 2) {
//                                    if (self.codableRisk[self.codableRisk.count - 2]).risk > 0.5 {
//                                        if self.codableRisk[self.codableRisk.count - 2].date.get(.day) + 1 == self.codableRisk.last?.date.get(.day) ?? 0 {
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
//                                }
//                            }
        //            print(self.average(numbers: self.codableRisk.map{$0.risk}))
                //}
//                            }
                    }
//            }
                    if self.healthData.isEmpty {
                        
                    } else {
                        
                       // }
                    }

            }
                  //  }
                    }
                }
           
            
           
    }
    func syncAllData() {
        
          
           // self.retrieveSleepAnalysis() { sleep in
                //let sleepingHours = sleep.map{$0.date.get(.hour)}
               
                    //self.getHealthData(type: .heartRate, dateDistanceType: .Week, dateDistance: self.onboarding ? 7 : 30, endDate: Date()) { value in
            let earlyDate = Calendar.current.date(
              byAdding: .month,
              value: -3,
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
                  byAdding: .minute,
                  value: -5,
                  to: data.date)
                let lateDate = Calendar.current.date(
                  byAdding: .minute,
                  value: 5,
                  to: data.date)
                print(earlyDate)
                print(lateDate)
                
                self.getHeartRateHealthData(startDate: earlyDate ?? Date(), endDate:  lateDate ?? Date())
//                    print(data)
            }
           
           
                //}
           // self.getHealthData(type: .heartRate, dateDistanceType: .Month, dateDistance: self.onboarding ? 24 : 24, endDate: Date()) { [self] value in
//                            let filtered = self.codableRisk.filter {
//                                return $0.risk > 0
//                            }
//                            print(filtered)
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
           // let riskScore = self.getRiskScoreAll(bedTime: 0, wakeUpTime: 24, data: self.healthData).0.risk
                    self.getRiskScorev2()
//                let riskScore = self.getRiskScore(bedTime: 0, wakeUpTime: 4, data: self.healthData).0.risk
                
//                        if  riskScore > 0.5 && riskScore != 21.0 {
////                                print("RISK DAYS")
////                                print(codableRisk[codableRisk.count - 2].date.get(.day) + 1)
////                                print(codableRisk.last?.date.get(.day))
//                            if self.codableRisk.indices.contains(self.codableRisk.count - 2) {
//                                if (self.codableRisk[self.codableRisk.count - 2]).risk > 0.5 {
//                                    if self.codableRisk[self.codableRisk.count - 2].date.get(.day) + 1 == self.codableRisk.last?.date.get(.day) ?? 0 {
//
//
//
//                            LocalNotifications.schedule(permissionStrategy: .askSystemPermissionIfNeeded) {
//                                Today()
//                                    .at(hour: Date().get(.hour), minute: Date().get(.minute) + 1)
//                                    .schedule(title: "Significant Risk", body: "Your health data may indicate that you may be becoming sick")
//                            }
//                            }
//
//                            }
//                            }
//                        }
    //            print(self.average(numbers: self.codableRisk.map{$0.risk}))
            //}
//                            }
                }
//            }
                if self.healthData.isEmpty {
                    
                } else {
                    
                   // }
                }

        }
              //  }
           
                }
    
//    func getRiskScoreAll(bedTime: Int, wakeUpTime: Int, data: [HealthData]) -> (Risk, [CodableRisk]) {
//            //DispatchQueue.main.asyncAfter(deadline: .now() + 30.0) {
//            print("Calculating Risk...")
//       // DispatchQueue.main.async {
//
//            var medianHeartrate = 0.0
//                let url3 = self.getDocumentsDirectory().appendingPathComponent("risk.txt")
//            do {
//
//                let input = try String(contentsOf: url3)
//
//
//                let jsonData = Data(input.utf8)
//                do {
//                    let decoder = JSONDecoder()
//
//                    do {
//                        let codableRisk = try decoder.decode([CodableRisk].self, from: jsonData)
//
//                       // medianHeartrate = codableRisk.map{Int($0.risk)}.median()
//
//
//                    } catch {
//                        print(error.localizedDescription)
//                    }
//                }
//            } catch {
//
//            }
//
//
//
//            let filteredToNight = self.healthData.filter {
//                return ($0.date.get(.hour) > bedTime && $0.date.get(.hour) < 24) || ($0.date.get(.hour) > 0 && $0.date.get(.hour) < wakeUpTime)
//            }
//
//            let filteredToHeartRate = filteredToNight.filter {
//                return $0.title == HKQuantityTypeIdentifier.heartRate.rawValue
//            }
//
//            let filteredToSteps = filteredToNight.filter {
//                return $0.title == HKQuantityTypeIdentifier.stepCount.rawValue
//            }
//                let filteredToR = filteredToNight.filter {
//                    return $0.title == HKQuantityTypeIdentifier.respiratoryRate.rawValue
//                }
//            let filteredToMoreThanZeroSteps = filteredToSteps.filter {
//                return $0.data != 0
//            }
//            var todayHeartRates = [Double]()
//            var heartRates = [Double]()
//            var averageHRPerNight = [Double]()
//            var dates = [Date]()
//            //print(healthData.map{$0.date})
//                for month in 0...12 {
//                    //averageHRPerNight = []
//                    dates = []
//                    heartRates = []
//                    let filteredToMonth = filteredToHeartRate.filter { data in
//                        return data.date.get(.month) == month
//                    }
//            for day in 0...30 {
//            let filteredToDay = filteredToMonth.filter { data in
//                return data.date.get(.day) == day
//            }
//                heartRates = []
//               // print(filteredToDay)
//                if !filteredToMoreThanZeroSteps.map({$0.date.get(.hour)}).contains((filteredToDay.last?.date ?? Date()).get(.hour)) {
//                    //if filteredToR.map({$0.date.get(.hour)}).contains((filteredToDay.last?.date ?? Date()).get(.hour)) {
//                    if !filteredToDay.isEmpty {
//                      //  print(filteredToDay.last?.date.get(.day) == day)
//                        #warning("Change back")
////                        if 25 == day && month == 4 {
////                            todayHeartRates.append(filteredToDay.isEmpty ? filteredToDay.last?.data ?? 0.0 : average(numbers: filteredToDay.map{$0.data}))
////
////                        } else {
//                        heartRates.append(filteredToDay.isEmpty ? filteredToDay.last?.data ?? 0.0 : self.average(numbers: filteredToDay.map{$0.data}))
//                        //}
//
//
//                dates.append(filteredToDay.last?.date ?? Date())
//                    }
//
//            }
//                }
//              //  if !heartRates.isEmpty {
//                    let average = self.average(numbers: heartRates.filter{$0 != 0})
//                if !average.isNaN {
//                averageHRPerNight.append(average)
//                }
//           // }
//            }
//           print("averageHRPerNight")
//        print(averageHRPerNight.filter{$0 != 0.0})
//
//                for night in averageHRPerNight {
//                    #warning("exclude the night I am calculating the risk for from the overall medianHeartrate to ensure accuracy")
//                    if !averageHRPerNight.isEmpty {
//
//                        medianHeartrate = averageHRPerNight.filter {$0 != night && $0 != 0.0}.median()
//                        print(averageHRPerNight.filter {$0 != night})
//                        self.medianOfAverages = medianHeartrate
//                        UserDefaults.standard.set(self.medianOfAverages, forKey: "medianOfAverages")
//                    }
//
//                let riskScore = night >= medianHeartrate + 4 ? 1 : 0
//
//                let explanation =  riskScore == 1 ? [Explanation(image: .exclamationmarkCircle, explanation: "Your health data may indicate you have an illness"), Explanation(image: .heart, explanation: "Calculated from your average heartrate while asleep"),  Explanation(image: .app, explanation: "Alerts may be triggered from other factors than an illness, such as lack of sleep, intoxication, or intense exercise"), Explanation(image: .stethoscope, explanation: "This is not a medical diagnosis, it's an alert to consult with your doctor")] : [Explanation(image: .checkmark, explanation: "Your health data may indicate you do not have an illness"), Explanation(image: .chartPie, explanation: "Calculated from your average heartrate while asleep"), Explanation(image: .stethoscope, explanation: "This is not a medical diagnosis or lack thereof, you may still have an illness")]
//            let risk = Risk(id: UUID().uuidString, risk: CGFloat(riskScore), explanation: explanation)
//            #warning("Change to a highher value to prevent bad data (because of low amount of data)")
//            if averageHRPerNight.count > 0 {
//            withAnimation(.easeOut(duration: 1.3)) {
//
//            self.risk = risk
//            }
//                self.codableRisk.append(CodableRisk(id: risk.id, date: dates.last ?? Date(), risk: risk.risk, explanation: [String]()))
//                //print("YAH")
//            } else {
//                //#warning("If last night's heartrate is empty, then alert goes off incorrectly")
//                self.risk = Risk(id: "NoData", risk: CGFloat(21), explanation: [Explanation(image: .exclamationmarkCircle, explanation: "Wear your Apple Watch as you sleep to see your data")])
//               // print("ooooof")
//            }
//                //print(self.codableRisk)
//           // }
//            }
//            //}
//            return (self.risk, codableRisk)
//        }
    func getRiskScoreAll(bedTime: Int, wakeUpTime: Int, data: [HealthData]) -> (Risk, [CodableRisk]) {
                //DispatchQueue.main.asyncAfter(deadline: .now() + 30.0) {
                print("Calculating Risk...")
                if !healthData.isEmpty {
                var medianHeartrate = 0.0
                    let url3 = self.getDocumentsDirectory().appendingPathComponent("risk.txt")
                do {
                    
                    let input = try String(contentsOf: url3)
                    
                    
                    let jsonData = Data(input.utf8)
                    do {
                        let decoder = JSONDecoder()
                        
                        do {
                            let codableRisk = try decoder.decode([CodableRisk].self, from: jsonData)
                            
                           // medianHeartrate = codableRisk.map{Int($0.risk)}.median()
                            
                         
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                } catch {
                    
                }
                    
                    
                    
                let filteredToNight = healthData//.filter {
//                    return ($0.date.get(.hour) > bedTime && $0.date.get(.hour) < 24) || ($0.date.get(.hour) > 0 && $0.date.get(.hour) < wakeUpTime)
//                }
                   
                let filteredToHeartRate = filteredToNight.filter {
                    return $0.title == HKQuantityTypeIdentifier.heartRate.rawValue
                }
                   
                let filteredToSteps = filteredToNight.filter {
                    return $0.title == HKQuantityTypeIdentifier.stepCount.rawValue
                }
                let filteredToMoreThanZeroSteps = filteredToSteps.filter {
                    return $0.data != 0
                }
                var todayHeartRates = [Double]()
                var heartRates = [Double]()
                var averageHRPerNight = [Double]()
                var dates = [Date]()
                //print(healthData.map{$0.date})
                    for month in 0...12 {
                        //averageHRPerNight = []
                        dates = []
                        heartRates = []
                        let filteredToMonth = filteredToHeartRate.filter { data in
                            return data.date.get(.month) == month
                        }
                for day in 0...30 {
                let filteredToDay = filteredToMonth.filter { data in
                    return data.date.get(.day) == day
                }
                    heartRates = []
                   // print(filteredToDay)
               
                    //if !filteredToMoreThanZeroSteps.map({$0.date}).contains(filteredToDay.last?.date ?? Date()) {
                        if !filteredToDay.isEmpty {
                          //  print(filteredToDay.last?.date.get(.day) == day)
                            #warning("Change back")
    //                        if 25 == day && month == 4 {
    //                            todayHeartRates.append(filteredToDay.isEmpty ? filteredToDay.last?.data ?? 0.0 : average(numbers: filteredToDay.map{$0.data}))
    //
    //                        } else {
                                heartRates.append(filteredToDay.isEmpty ? filteredToDay.last?.data ?? 0.0 : average(numbers: filteredToDay.map{$0.data}))
                            //}
                        
                            
                    dates.append(filteredToDay.last?.date ?? Date())
                        }
                    
               // }
                  //  if !heartRates.isEmpty {
                        let average = average(numbers: heartRates)
                    if !average.isNaN {
                    averageHRPerNight.append(average)
                    }
                }
                }
               print("averageHRPerNight")
               print(averageHRPerNight)
                    medianHeartrate = averageHRPerNight.removeDuplicates().median()
                    //print(averageHRPerNight.filter {$0 != night})
                    for night in averageHRPerNight.removeDuplicates() {
//                        #warning("exclude the night I am calculating the risk for from the overall medianHeartrate to ensure accuracy")
//                        if !averageHRPerNight.isEmpty {
//
//
//                        }
                        
                    let riskScore = night >= medianHeartrate + 4 ? 1 : 0
                    
                    let explanation =  riskScore == 1 ? [Explanation(image: .exclamationmarkCircle, explanation: "Your health data may indicate you have an illness"), Explanation(image: .heart, explanation: "Calculated from your average heartrate while asleep"),  Explanation(image: .app, explanation: "Alerts may be triggered from other factors than an illness, such as lack of sleep, intoxication, or intense exercise"), Explanation(image: .stethoscope, explanation: "This is not a medical diagnosis, it's an alert to consult with your doctor")] : [Explanation(image: .checkmark, explanation: "Your health data may indicate you do not have an illness"), Explanation(image: .chartPie, explanation: "Calculated from your average heartrate while asleep"), Explanation(image: .stethoscope, explanation: "This is not a medical diagnosis or lack thereof, you may still have an illness")]
                let risk = Risk(id: UUID().uuidString, risk: CGFloat(riskScore), explanation: explanation)
                #warning("Change to a highher value to prevent bad data (because of low amount of data)")
                if averageHRPerNight.count > 0 {
                withAnimation(.easeOut(duration: 1.3)) {
                    
                self.risk = risk
                }
                    self.codableRisk.append(CodableRisk(id: risk.id, date: dates.last ?? Date(), risk: risk.risk, explanation: [String]()))
                    //print("YAH")
                } else {
                    //#warning("If last night's heartrate is empty, then alert goes off incorrectly")
                    self.risk = Risk(id: "NoData", risk: CGFloat(21), explanation: [Explanation(image: .exclamationmarkCircle, explanation: "Wear your Apple Watch as you sleep to see your data")])
                   // print("ooooof")
                }
                    //print(self.codableRisk)
                }
                }
                //}
                return (self.risk, codableRisk)
            }
    var cancellableBag = Set<AnyCancellable>()
    var cancellableBag2 = Set<AnyCancellable>()
    //@Published var pubHealth: AnyPublisher<HealthData?, Never>
   // var pubHealth: AnyPublisher<HealthData?, Never>
    func getActiveEnergyHealthData(startDate: Date, endDate: Date) {
       
        healthStore
            .get(sample: HKSampleType.quantityType(forIdentifier: .activeEnergyBurned)!, start: startDate, end: endDate)
            .receive(on: DispatchQueue.main)
            .replaceError(with: [HKQuantitySample]())
            .sink(receiveCompletion: { subscription in
                print(1)
            }, receiveValue: { samples in
               print(2)
                for sample in samples {
                    print(sample)
                    //data.append(sample.quantity.is(compatibleWith: .percent()) ? sample.quantity.doubleValue(for: .percent()) : sample.quantity.is(compatibleWith: .count()) ? sample.quantity.doubleValue(for: .count()) : sample.quantity.is(compatibleWith: .inch()) ? sample.quantity.doubleValue(for: .inch()) : sample.quantity.is(compatibleWith: HKUnit.count().unitDivided(by: HKUnit.minute())) ? sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute())) : sample.quantity.is(compatibleWith: .largeCalorie()) ? sample.quantity.doubleValue(for: .largeCalorie()) : sample.quantity.doubleValue(for: HKUnit.mile().unitDivided(by: HKUnit.hour())))
                    print(sample.startDate)
                    print(sample.endDate)
                    print( sample.quantity.doubleValue(for: self.calorieQuantity))
                    if sample.quantity.doubleValue(for: self.calorieQuantity) < 20 && sample.quantity.doubleValue(for: self.calorieQuantity) != 0 {
                    self.healthData.append(HealthData(id: UUID().uuidString, type: .Health, title: HKSampleType.quantityType(forIdentifier: .activeEnergyBurned)?.identifier ?? "", text: "", date: sample.startDate, data: sample.endDate.timeIntervalSince1970))
                    
                    } else {
                        print("GOOD")
                    }
                }
                
            }).store(in: &cancellableBag)
    }
    func getHeartRateHealthData(startDate: Date, endDate: Date) {
       
//       healthStore
//            .statistic(for: HKObjectType.quantityType(forIdentifier: .heartRate)!, with: .discreteAverage, from: startDate, to: endDate)
//            .map({HealthData(id: UUID().uuidString, type: .Health, title: HKQuantityTypeIdentifier.heartRate.rawValue, text: "", date: $0.startDate, data: $0.averageQuantity()?.doubleValue(for: self.heartrateQuantity) ?? 0) })
//            .replaceError(with: HealthData(id: "", type: .Health, title: "", text: "", date: Date(), data: 0.0))
//            //.assertNoFailure()
//
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: { subscription in
//                print(1)
//            }, receiveValue: { sample in
//               print(2)
//
//                    print(sample)
//                    //data.append(sample.quantity.is(compatibleWith: .percent()) ? sample.quantity.doubleValue(for: .percent()) : sample.quantity.is(compatibleWith: .count()) ? sample.quantity.doubleValue(for: .count()) : sample.quantity.is(compatibleWith: .inch()) ? sample.quantity.doubleValue(for: .inch()) : sample.quantity.is(compatibleWith: HKUnit.count().unitDivided(by: HKUnit.minute())) ? sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute())) : sample.quantity.is(compatibleWith: .largeCalorie()) ? sample.quantity.doubleValue(for: .largeCalorie()) : sample.quantity.doubleValue(for: HKUnit.mile().unitDivided(by: HKUnit.hour())))
//
//
//                    self.healthData.append(HealthData(id: UUID().uuidString, type: .Health, title: HKSampleType.quantityType(forIdentifier: .heartRate)?.identifier ?? "", text: "", date: sample.date, data: sample.data))
//
//
//
//
//
//            }).store(in: &cancellableBag2)
//    }

        healthStore
            .get(sample: HKSampleType.quantityType(forIdentifier: .heartRate)!, start: startDate, end: endDate)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { subscription in
                print(1)
            }, receiveValue: { samples in
               print(2)
                
                if samples.count > 2 {
                self.healthData.append(HealthData(id: UUID().uuidString, type: .Health, title: HKSampleType.quantityType(forIdentifier: .heartRate)?.identifier ?? "", text: "", date: startDate, data: self.average(numbers: samples.map{$0.quantity.doubleValue(for: self.heartrateQuantity)})))
                }

            }).store(in: &cancellableBag2)
    }
    func getRiskScorev2() {
        let filteredToHeartRate = healthData.filter {
            return $0.title == HKQuantityTypeIdentifier.heartRate.rawValue && !$0.data.isNaN
        }
        let filteredToSteps = healthData.filter {
            return $0.title == HKQuantityTypeIdentifier.stepCount.rawValue
        }
        let filteredToCal = healthData.filter {
            return $0.title == HKQuantityTypeIdentifier.activeEnergyBurned.rawValue
        }
//            let filteredToO = self.healthData.filter {
//                return $0.title == HKQuantityTypeIdentifier.oxygenSaturation.rawValue
//            }
//            let filteredToR = self.healthData.filter {
//                return $0.title == HKQuantityTypeIdentifier.respiratoryRate.rawValue
//            }
        let filteredToMoreThanZeroSteps = filteredToSteps.filter {
            return $0.data != 0
        }
//        let heartrateFilteredToZeroStepsAndBelow5Cal =  filteredToHeartRate.filter {
//            return filteredToMoreThanZeroSteps.map{$0.date.get(.hour)}.contains($0.date.get(.hour)) && filteredToMoreThanZeroSteps.map{$0.date.get(.hour)}.contains($0.date.get(.hour))
    
        var averagePerNights = [Double]()
        for day in 0...32 {
            let filteredToDay = filteredToHeartRate.filter {
                return $0.date.get(.day) == day && $0.date.get(.day) != Date().get(.day)
            }
            print(filteredToDay)
            
            averagePerNights.append(average(numbers: filteredToDay.map{$0.data}))
            
        }
        let median = averagePerNights.filter{!$0.isNaN}.median()
        print("MEDIAN")
        print(median)
        let filteredToLastNight = filteredToHeartRate.filter {
            return $0.date.get(.day) == Date().get(.day)
        }
        let riskScore = average(numbers: filteredToLastNight.map{$0.data}) >= median + 4 ? 1 : 0
        
        let explanation =  riskScore == 1 ? [Explanation(image: .exclamationmarkCircle, explanation: "Your health data may indicate you have an illness"), Explanation(image: .heart, explanation: "Calculated from your average heartrate while asleep"),  Explanation(image: .app, explanation: "Alerts may be triggered from other factors than an illness, such as lack of sleep, intoxication, or intense exercise"), Explanation(image: .stethoscope, explanation: "This is not a medical diagnosis, it's an alert to consult with your doctor")] : [Explanation(image: .checkmark, explanation: "Your health data may indicate you do not have an illness"), Explanation(image: .chartPie, explanation: "Calculated from your average heartrate while asleep"), Explanation(image: .stethoscope, explanation: "This is not a medical diagnosis or lack thereof, you may still have an illness")]
    let risk = Risk(id: UUID().uuidString, risk: CGFloat(riskScore), explanation: explanation)
    #warning("Change to a highher value to prevent bad data (because of low amount of data)")
    if averagePerNights.count > 3 {
    withAnimation(.easeOut(duration: 1.3)) {
        
    self.risk = risk
    }
        self.codableRisk.append(CodableRisk(id: risk.id, date: Date(), risk: risk.risk, explanation: [String]()))
        //print("YAH")
    } else {
        //#warning("If last night's heartrate is empty, then alert goes off incorrectly")
        self.risk = Risk(id: "NoData", risk: CGFloat(21), explanation: [Explanation(image: .exclamationmarkCircle, explanation: "Wear your Apple Watch as you sleep to see your data")])
       // print("ooooof")
    }
    }
    func getRiskScore(bedTime: Int, wakeUpTime: Int, data: [HealthData]) -> (Risk, [CodableRisk]) {
                  //DispatchQueue.main.asyncAfter(deadline: .now() + 30.0) {
                  print("Calculating Risk...")
                  if !healthData.isEmpty {
                  var medianHeartrate = 0.0
                      var medianRrate = 0.0
                      var medianOrate = 0.0
                      let url3 = self.getDocumentsDirectory().appendingPathComponent("risk.txt")
                  do {
                      
                      let input = try String(contentsOf: url3)
                      
                      
                      let jsonData = Data(input.utf8)
                      do {
                          let decoder = JSONDecoder()
                          
                          do {
                              let codableRisk = try decoder.decode([CodableRisk].self, from: jsonData)
                              
                             // medianHeartrate = codableRisk.map{Int($0.risk)}.median()
                              
                           
                          } catch {
                              print(error.localizedDescription)
                          }
                      }
                  } catch {
                      
                  }
                  
                  let filteredToNight = healthData
                  let filteredToHeartRate = filteredToNight.filter {
                      return $0.title == HKQuantityTypeIdentifier.heartRate.rawValue
                  }
                  let filteredToSteps = filteredToNight.filter {
                      return $0.title == HKQuantityTypeIdentifier.stepCount.rawValue
                  }
                  let filteredToO = healthData.filter {
                          return $0.title == HKQuantityTypeIdentifier.oxygenSaturation.rawValue
                      }
                  let filteredToR = healthData.filter {
                          return $0.title == HKQuantityTypeIdentifier.respiratoryRate.rawValue
                      }
                  let filteredToMoreThanZeroSteps = filteredToSteps.filter {
                      return $0.data != 0
                  }
                  var todayHeartRates = [Double]()
                      var todayORates = [Double]()
                      var todayRRates = [Double]()
                  var heartRates = [Double]()
                      var rRates = [Double]()
                      var oRates = [Double]()
                  var averageHRPerNight = [Double]()
                      var averageOPerNight = [Double]()
                      var averageRPerNight = [Double]()
                  var dates = [Date]()
                  //print(healthData.map{$0.date})
                      for month in 0...12 {
                  for day in 0...32 {
                  let filteredToDay = filteredToHeartRate.filter { data in
                      return data.date.get(.day) == day && data.date.get(.month) == month
                  }
                      let filteredToDayO = filteredToO.filter { data in
                          return data.date.get(.day) == day && data.date.get(.month) == month
                      }
                      let filteredToDayR = filteredToR.filter { data in
                          return data.date.get(.day) == day && data.date.get(.month) == month
                      }
                    print("R.....")
                      print(filteredToDayR)
                      heartRates = []
                      rRates = []
                      heartRates = []
                          // print(filteredToDay)
                      //if !filteredToDayR.indices.contains(1) {
                      if Date().get(.day) == day {
                          todayRRates.append(filteredToDayR.count == 1 ? filteredToDayR.last?.data ?? 0.0 : average(numbers: filteredToDayR.map{$0.data}))
                      } else {
                          rRates.append(filteredToDayR.count == 1 ? filteredToDayR.last?.data ?? 0.0 : average(numbers: filteredToDayR.map{$0.data}))
                      
                      }
                      //}
                      //if !filteredToMoreThanZeroSteps.map({$0.date}).contains(filteredToDay.last?.date ?? Date()) {
                          
                          //if !filteredToDay.indices.contains(1) {
                              if Date().get(.day) == day {
  //                                todayRRates.append(filteredToDayR.count == 1 ? filteredToDayR.last?.data ?? 0.0 : average(numbers: filteredToDayR.map{$0.data}))
                                  todayHeartRates.append(filteredToDay.isEmpty ? filteredToDay.last?.data ?? 0.0 : average(numbers: filteredToDay.map{$0.data}))
                                  todayORates.append(filteredToDayO.isEmpty ? filteredToDayO.last?.data ?? 0.0 : average(numbers: filteredToDayO.map{$0.data}))
                                  
                                 
                              } else {
                                  heartRates.append(filteredToDay.isEmpty ? filteredToDay.last?.data ?? 0.0 : average(numbers: filteredToDay.map{$0.data}))
                                  
                                  
                                 // oRates.append(filteredToDayR.isEmpty ? filteredToDayR.last?.data ?? 0.0 : average(numbers: filteredToDayR.map{$0.data}))
                              }
                          
                              
                      dates.append(filteredToDay.last?.date ?? Date())
                         // }
                      
                  }
                      
                      if !heartRates.isEmpty {
                          averageHRPerNight.append(average(numbers: heartRates))
                      }
                      if !rRates.isEmpty {
                          averageRPerNight.append(average(numbers: rRates))
                          averageOPerNight.append(average(numbers: oRates))
                      }
                      
                  }
                     // }
                 print("averageHRPerNight")
                      print(averageHRPerNight.filter{$0 != 0})
                      //if !averageHRPerNight.isEmpty {
                          if !averageHRPerNight.indices.contains(1) {
                              medianHeartrate = averageHRPerNight.filter{$0 > 0}.median()
                      }
                      if !averageRPerNight.indices.contains(1) {
                          medianRrate = averageRPerNight.median()
                          medianOrate = averageOPerNight.median()
                      }
                  
                      var riskScore = self.average(numbers: todayHeartRates) > medianHeartrate + 4 ? 1.0 : 0.0
  //                    if medianOrate > average(numbers: todayORates) {
  //                        riskScore += 0.5
  //                    }
                      print("MEDIAN R")
                      print(medianRrate)
                      
                      print("AVG R")
                      print(average(numbers: todayRRates))
                      if medianRrate * 1.6  < average(numbers: todayRRates) {
                          riskScore += 1.0
                      }
                   
                      let explanation =  riskScore == 1 ? [Explanation(image: .exclamationmarkCircle, explanation: "Your health data may indicate you have an illness"), Explanation(image: .heart, explanation: "Calculated from your average heartrate while asleep, respiratory rate, and oxygen saturation"),  Explanation(image: .app, explanation: "Alerts may be triggered from other factors than an illness, such as lack of sleep, intoxication, or intense exercise"), Explanation(image: .stethoscope, explanation: "This is not a medical diagnosis, it's an alert to consult with your doctor")] : [Explanation(image: .checkmark, explanation: "Your health data may indicate you do not have an illness"), Explanation(image: .chartPie, explanation: "Calculated from your average heartrate while asleep, respiratory rate, and oxygen saturation"), Explanation(image: .stethoscope, explanation: "This is not a medical diagnosis or lack thereof, you may still have an illness")]
                  let risk = Risk(id: UUID().uuidString, risk: CGFloat(riskScore), explanation: explanation)
                  #warning("Change to a highher value to prevent bad data (because of low amount of data)")
                  if averageHRPerNight.count > 0 {
                  withAnimation(.easeOut(duration: 1.3)) {
                      
                  self.risk = risk
                  }
                      self.codableRisk.append(CodableRisk(id: risk.id, date: dates.last ?? Date(), risk: risk.risk, explanation: [String]()))
                  } else {
                      //#warning("If last night's heartrate is empty, then alert goes off incorrectly")
                      self.risk = Risk(id: "NoData", risk: CGFloat(21), explanation: [Explanation(image: .exclamationmarkCircle, explanation: "Wear your Apple Watch as you sleep to see your data")])
                  }
                      //print(self.codableRisk)
                  }
                  
                  //}
                  return (self.risk, codableRisk)
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

