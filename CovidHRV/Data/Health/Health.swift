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
    
    let calorieQuantity = HKUnit(from: .calorie)
    let heartrateQuantity = HKUnit(from: "count/min")
      
    init() {

        backgroundDelivery()
     
        
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
                
                    self.getHeartRateHealthData(startDate: earlyDate ?? Date(), endDate:  lateDate ?? Date())

                }
               
               
               
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
              
                        self.getRiskScorev2()

                    }

                    if self.healthData.isEmpty {
                        
                    } else {
                        

                    }

            }
                    }
                }
           
            
           
    }
    func syncAllData() {
      
            let earlyDate = Calendar.current.date(
              byAdding: .month,
              value: -3,
              to: Date())
            print(earlyDate)
           
           
                self.getActiveEnergyHealthData(startDate: earlyDate ?? Date(), endDate: Date())
         
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            for data in self.healthData {
               print(data)
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

            }
           
           
         
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
         
                    self.getRiskScorev2()

                }

                if self.healthData.isEmpty {
                    
                } else {
                    

                }

        }

           
                }
    
    func getRiskScoreAll(bedTime: Int, wakeUpTime: Int, data: [HealthData]) -> (Risk, [CodableRisk]) {
              
                print("Calculating Risk...")
                if !healthData.isEmpty {
                var medianHeartrate = 0.0
             
                    
                    
                    
                let filteredToNight = healthData

                   
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
              
                    for month in 0...12 {
                      
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
                    
               
                        let average = average(numbers: heartRates)
                    if !average.isNaN {
                    averageHRPerNight.append(average)
                    }
                }
                }
               print("averageHRPerNight")
               print(averageHRPerNight)
                    medianHeartrate = averageHRPerNight.removeDuplicates().median()
                   
                    for night in averageHRPerNight.removeDuplicates() {

                        
                    let riskScore = night >= medianHeartrate + 4 ? 1 : 0
                    
                    let explanation =  riskScore == 1 ? [Explanation(image: .exclamationmarkCircle, explanation: "Your health data may indicate you have an illness"), Explanation(image: .heart, explanation: "Calculated from your average heartrate while asleep"),  Explanation(image: .app, explanation: "Alerts may be triggered from other factors than an illness, such as lack of sleep, intoxication, or intense exercise"), Explanation(image: .stethoscope, explanation: "This is not a medical diagnosis, it's an alert to consult with your doctor")] : [Explanation(image: .checkmark, explanation: "Your health data may indicate you do not have an illness"), Explanation(image: .chartPie, explanation: "Calculated from your average heartrate while asleep"), Explanation(image: .stethoscope, explanation: "This is not a medical diagnosis or lack thereof, you may still have an illness")]
                let risk = Risk(id: UUID().uuidString, risk: CGFloat(riskScore), explanation: explanation)
                #warning("Change to a highher value to prevent bad data (because of low amount of data)")
                if averageHRPerNight.count > 0 {
                withAnimation(.easeOut(duration: 1.3)) {
                    
                self.risk = risk
                }
                    self.codableRisk.append(CodableRisk(id: risk.id, date: dates.last ?? Date(), risk: risk.risk, explanation: [String]()))
                  
                } else {
                  
                    self.risk = Risk(id: "NoData", risk: CGFloat(21), explanation: [Explanation(image: .exclamationmarkCircle, explanation: "Wear your Apple Watch as you sleep to see your data")])
                  
                }
                   
                }
                }
             
                return (self.risk, codableRisk)
            }
    var cancellableBag = Set<AnyCancellable>()
    var cancellableBag2 = Set<AnyCancellable>()
   
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
                    
                    if sample.quantity.doubleValue(for: self.calorieQuantity) < 20 && sample.quantity.doubleValue(for: self.calorieQuantity) != 0 {
                    self.healthData.append(HealthData(id: UUID().uuidString, type: .Health, title: HKSampleType.quantityType(forIdentifier: .activeEnergyBurned)?.identifier ?? "", text: "", date: sample.startDate, data: sample.endDate.timeIntervalSince1970))
                    
                    } else {
                       
                    }
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

        let filteredToMoreThanZeroSteps = filteredToSteps.filter {
            return $0.data != 0
        }

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
     
    } else {
      
        self.risk = Risk(id: "NoData", risk: CGFloat(21), explanation: [Explanation(image: .exclamationmarkCircle, explanation: "Wear your Apple Watch as you sleep to see your data")])
    
    }
    }
    func getRiskScore(bedTime: Int, wakeUpTime: Int, data: [HealthData]) -> (Risk, [CodableRisk]) {
                 
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
                     
                      if Date().get(.day) == day {
                          todayRRates.append(filteredToDayR.count == 1 ? filteredToDayR.last?.data ?? 0.0 : average(numbers: filteredToDayR.map{$0.data}))
                      } else {
                          rRates.append(filteredToDayR.count == 1 ? filteredToDayR.last?.data ?? 0.0 : average(numbers: filteredToDayR.map{$0.data}))
                      
                      }
                   
                              if Date().get(.day) == day {
  
                                  todayHeartRates.append(filteredToDay.isEmpty ? filteredToDay.last?.data ?? 0.0 : average(numbers: filteredToDay.map{$0.data}))
                                  todayORates.append(filteredToDayO.isEmpty ? filteredToDayO.last?.data ?? 0.0 : average(numbers: filteredToDayO.map{$0.data}))
                                  
                                 
                              } else {
                                  heartRates.append(filteredToDay.isEmpty ? filteredToDay.last?.data ?? 0.0 : average(numbers: filteredToDay.map{$0.data}))
                                  
                                  
                                 
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
                      
                  }
                  
             
                  return (self.risk, codableRisk)
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

