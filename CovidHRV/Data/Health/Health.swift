//
//  Health.swift
//  Health
//
//  Created by Andreas on 8/17/21.
//

import SwiftUI
import HealthKit
import NiceNotifications

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
                  
                    for type in self.readData {
                        self.getHealthData(type: type, dateDistanceType: .Week, dateDistance: self.onboarding ? 24 : 24, endDate: Date()) { value in
                        }
                    }
                self.getHealthData(type: .heartRate, dateDistanceType: .Month, dateDistance: self.onboarding ? 24 : 24, endDate: Date()) { [self] value in
//                            let filtered = self.codableRisk.filter {
//                                return $0.risk > 0
//                            }
//                            print(filtered)
                           
                            //let riskScore = self.getRiskScore(bedTime: sleepingHours.max() ?? 0, wakeUpTime: sleepingHours.min() ?? 0, data: value).0.risk
                            
                            let riskScore = self.getRiskScore(bedTime: 0, wakeUpTime: 4, data: value).0.risk
                    print()
                            if  riskScore > 0.5 && riskScore != 21.0 {
//                                print("RISK DAYS")
//                                print(codableRisk[codableRisk.count - 2].date.get(.day) + 1)
//                                print(codableRisk.last?.date.get(.day))
                                if self.codableRisk.indices.contains(codableRisk.count - 2) {
                                    if (codableRisk[codableRisk.count - 2]).risk > 0.5 {
                                        if codableRisk[codableRisk.count - 2].date.get(.day) + 1 == codableRisk.last?.date.get(.day) ?? 0 {
                                            
                                       
                                
                                LocalNotifications.schedule(permissionStrategy: .askSystemPermissionIfNeeded) {
                                    Today()
                                        .at(hour: Date().get(.hour), minute: Date().get(.minute) + 1)
                                        .schedule(title: "Significant Risk", body: "Your health data may indicate that you may be becoming sick")
                                }
                                }
                            }
                                }
        //            print(self.average(numbers: self.codableRisk.map{$0.risk}))
                //}
                            }
            }
                    if self.healthData.isEmpty {
                        
                    } else {
                        
                       // }

            }
                  //  }
                    }
                }
           
            
           
    }
    
    func convertSleepStartDate(StartDate: Date) -> Date {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyy-MM-dd '18':'00':'01' +0000"
        let dateString = dateFormatter.string(from: StartDate)
        dateFormatter.dateFormat = "yyy-MM-dd HH:mm:ss +0000"
        let date = dateFormatter.date(from: dateString)
        let datePrior = Calendar.current.date(byAdding: .hour, value: -24, to: date!)
        print(datePrior as Any)

        return datePrior!
    }

    func convertSleepEndDate(EndDate: Date) -> Date {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyy-MM-dd '17':'59':'59' +0000"
        let dateString = dateFormatter.string(from: EndDate)
        dateFormatter.dateFormat = "yyy-MM-dd HH:mm:ss +0000"
        let date = dateFormatter.date(from: dateString)
        print(date as Any)

        return date!
    }
   
    
    func retrieveSleepAnalysis(completionHandler: @escaping ([HealthData]) -> Void) {
        
        // first, we define the object type we want
        if let sleepType = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis) {
            
            // Use a sortDescriptor to get the recent data first
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            
            // we create our query with a block completion to execute
            let query = HKSampleQuery(sampleType: sleepType, predicate: nil, limit: 30, sortDescriptors: [sortDescriptor]) { (query, tmpResult, error) -> Void in
                
                if error != nil {
                    
                    // something happened
                    return
                    
                }
                
                if let result = tmpResult {
                    
                    // do something with my data
                    for item in result {
                        if let sample = item as? HKCategorySample {
                            let value = (sample.value == HKCategoryValueSleepAnalysis.inBed.rawValue) ? "inBed" : "asleep"
                            let newData = HealthData(id: UUID().uuidString, type: .Health, title: value, text: "", date: sample.startDate, data: sample.endDate.timeIntervalSince1970)
                            self.healthData.append(newData)
                           
                            print("Healthkit sleep: \(sample.startDate) \(sample.endDate) - value: \(value)")
                        }
                    }
                }
                completionHandler(self.healthData)
            }
            
            // finally, we execute our query
            healthStore.execute(query)
        }
    }
    func calculateSleepHours(sample: HKSample) -> TimeInterval {

        let hours = sample.endDate.timeIntervalSince(sample.startDate) / 60 / 60

        return hours
    }
    func getHealthData(type: HKQuantityTypeIdentifier, dateDistanceType: DateDistanceType, dateDistance: Int, endDate: Date, completionHandler: @escaping ([HealthData]) -> Void) {
        
        DispatchQueue.main.async {
          
        let data = [HealthData]()
        let calendar = NSCalendar.current
        var anchorComponents = calendar.dateComponents([.day, .month, .year, .weekday], from: NSDate() as Date)
        
        let offset = (7 + anchorComponents.weekday! - 2) % 7
        
        anchorComponents.day! -= offset
        anchorComponents.hour = 2
        
        guard let anchorDate = Calendar.current.date(from: anchorComponents) else {
            fatalError("*** unable to create a valid date from the given components ***")
        }
        
        let interval = NSDateComponents()
        interval.minute = 30
        
            
        
        guard let startDate = calendar.date(byAdding: (dateDistanceType == .Week ? .day : .month), value: -dateDistance, to: endDate) else {
            fatalError("*** Unable to calculate the start date ***")
        }
        guard let quantityType3 = HKObjectType.quantityType(forIdentifier: type) else {
            fatalError("*** Unable to create a step count type ***")
        }
        
        let query3 = HKStatisticsCollectionQuery(quantityType: quantityType3,
                                                 quantitySamplePredicate: nil,
                                                 options: [type == .stepCount ? .mostRecent : .discreteAverage],
                                                 anchorDate: anchorDate,
                                                 intervalComponents: interval as DateComponents)
        
        query3.initialResultsHandler = {
            query, results, error in
            
            if let statsCollection = results {
                
                
                
                statsCollection.enumerateStatistics(from: startDate, to: endDate) { statistics, stop in
                    //print(statsCollection.sources().first?.name)
                    
                    //if statsCollection.sources().last?.name == UIDevice.current.name {
                    //print(UIDevice.current.name)
                    if let quantity = (type == .stepCount ? statistics.mostRecentQuantity() : statistics.averageQuantity()) {
                       
                        let date = statistics.startDate
                        //for: E.g. for steps it's HKUnit.count()
                        let value = quantity.is(compatibleWith: .percent()) ? quantity.doubleValue(for: .percent()) : quantity.is(compatibleWith: .count()) ? quantity.doubleValue(for: .count()) : quantity.is(compatibleWith: .inch()) ? quantity.doubleValue(for: .inch()) : quantity.is(compatibleWith: HKUnit.count().unitDivided(by: HKUnit.minute())) ? quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute())) : quantity.doubleValue(for: HKUnit.mile().unitDivided(by: HKUnit.hour()))
                        //data.append(UserData(id: UUID().uuidString, type: .Balance, title: type.rawValue, text: "", date: date, data: value))
                        
                        self.healthData.append(HealthData(id: UUID().uuidString, type: .Health, title: type.rawValue, text: "", date: date, data: value))
                        if type == .heartRate {
                        print(date)
                        }
                        
                        
                    }
                    //  }
                }
                
            }
            
            completionHandler(data)
        }
            self.convertHealthDataToChart(healthData: self.healthData) { _ in
            
        }
           
            self.healthStore.execute(query3)
        
        }
       
    }
   
//    func getRiskScore(bedTime: Int, wakeUpTime: Int, data: [HealthData]) -> (Risk, [CodableRisk]) {
//            //DispatchQueue.main.asyncAfter(deadline: .now() + 30.0) {
//            print("Calculating Risk...")
//            var medianHeartrate = 0.0
//        var medianRespiratoryRate = 0.0
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
//            let filteredToNight = healthData.filter {
//                return $0.date.get(.hour) > bedTime && $0.date.get(.hour) < wakeUpTime
//            }
//            let filteredToHeartRate = filteredToNight.filter {
//                return $0.title == HKQuantityTypeIdentifier.heartRate.rawValue
//            }
//            let filteredToSteps = filteredToNight.filter {
//                return $0.title == HKQuantityTypeIdentifier.stepCount.rawValue
//            }
//            let filteredToMoreThanZeroSteps = filteredToSteps.filter {
//                return $0.data != 0
//            }
//        let filteredToRespiratoryRate = healthData.filter {
//            return $0.title == HKQuantityTypeIdentifier.respiratoryRate.rawValue
//        }
//
//            var heartRates = [Double]()
//        var respiratoryRate = [Double]()
//            var dates = [Date]()
//
//        for day in 0...30 {
//            let filteredToDay = filteredToHeartRate.filter { data in
//                return data.date.get(.day) == day
//            }
//            for hour in bedTime...wakeUpTime {
//
//                let filteredToHour = filteredToDay.filter { data in
//                    return data.date.get(.hour) == hour
//                }
//
//                let filteredToHourR = filteredToHeartRate.filter { data in
//                    return data.date.get(.hour) == hour
//                }
//
//                if !filteredToMoreThanZeroSteps.map({$0.date}).contains(filteredToHour.last?.date ?? Date()) {
//                    heartRates.append(filteredToHeartRate.isEmpty ? filteredToHeartRate.last?.data ?? 0.0 : average(numbers: filteredToHeartRate.map{$0.data}))
//                    respiratoryRate.append(filteredToRespiratoryRate.isEmpty ? filteredToRespiratoryRate.last?.data ?? 0.0 : average(numbers: filteredToRespiratoryRate.map{$0.data}))
//                dates.append(filteredToHeartRate.last?.date ?? Date())
//
//                }
//            }
//            print(heartRates)
//            medianHeartrate = heartRates.median()
//       // medianRespiratoryRate = respiratoryRate.median()
//        //let respiratoryRiskScore = self.average(numbers: respiratoryRate) > medianRespiratoryRate + 3 ? 1 : 0
//        let riskScore = self.average(numbers: [self.average(numbers: heartRates) > medianHeartrate + 3 ? 1.0 : 0.0])// Double(respiratoryRiskScore)])
//        let explanation =  riskScore == 1 ? [Explanation(image: .exclamationmarkCircle, explanation: "Your health data may indicate you have an illness"), Explanation(image: .heart, explanation: "Calculated from your average heartrate while asleep"),  Explanation(image: .sleep, explanation: "Alerts may be triggered from other factors than an illness, such as lack of sleep, intoxication, or intense exercise"), Explanation(image: .stethoscope, explanation: "This is not a medical diagnosis, its an alert to consult with your doctor")] : [Explanation(image: .checkmark, explanation: "Your health data may indicate you do not have an illness"), Explanation(image: .chartPie, explanation: "Calculated from your average heartrate while asleep"), Explanation(image: .stethoscope, explanation: "This is not a medical diagnosis or lack thereof, you may still have an illness")]
//            let risk = Risk(id: UUID().uuidString, risk: CGFloat(riskScore), explanation: explanation)
//            #warning("Change to a highher value to prevent bad data (because of low amount of data)")
//            if heartRates.count > 0 {
//            withAnimation(.easeOut(duration: 1.3)) {
//
//            self.risk = risk
//            }
//                self.codableRisk.append(CodableRisk(id: risk.id, date: dates.last ?? Date(), risk: risk.risk, explanation: [String]()))
//            } else {
//                self.risk = Risk(id: "NoData", risk: CGFloat(21), explanation: [Explanation(image: .exclamationmarkCircle, explanation: "Wear your Apple Watch as you sleep to see your data")])
//            }
//        }
//                //print(self.codableRisk)
//
//            //}
//            return (self.risk, codableRisk)
//        }
  
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
                
                let filteredToNight = healthData.filter {
                    return ($0.date.get(.hour) > bedTime && $0.date.get(.hour) < 24) || ($0.date.get(.hour) < wakeUpTime && $0.date.get(.hour) > 0)
                }
                    
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
                for day in 0...32 {
                let filteredToDay = filteredToHeartRate.filter { data in
                    return data.date.get(.day) == day && data.date.get(.month) == Date().get(.month)
                }
                    let filteredToDayO = filteredToO.filter { data in
                        return data.date.get(.day) == day && data.date.get(.month) == Date().get(.month)
                    }
                    let filteredToDayR = filteredToR.filter { data in
                        return data.date.get(.day) == day && data.date.get(.month) == Date().get(.month)
                    }
                  print("R.....")
                    print(filteredToDayR)
                    heartRates = []
                    rRates = []
                    heartRates = []
                        // print(filteredToDay)
                    if !filteredToDayR.indices.contains(1) {
                    if Date().get(.day) == day {
                        todayRRates.append(filteredToDayR.count == 1 ? filteredToDayR.last?.data ?? 0.0 : average(numbers: filteredToDayR.map{$0.data}))
                    } else {
                        rRates.append(filteredToDayR.count == 1 ? filteredToDayR.last?.data ?? 0.0 : average(numbers: filteredToDayR.map{$0.data}))
                    
                    }
                    }
                    if !filteredToMoreThanZeroSteps.map({$0.date}).contains(filteredToDay.last?.date ?? Date()) {
                        
                        if !filteredToDay.indices.contains(1) {
                            if Date().get(.day) == day {
//                                todayRRates.append(filteredToDayR.count == 1 ? filteredToDayR.last?.data ?? 0.0 : average(numbers: filteredToDayR.map{$0.data}))
                                todayHeartRates.append(filteredToDay.isEmpty ? filteredToDay.last?.data ?? 0.0 : average(numbers: filteredToDay.map{$0.data}))
                                todayORates.append(filteredToDayO.isEmpty ? filteredToDayO.last?.data ?? 0.0 : average(numbers: filteredToDayO.map{$0.data}))
                                
                               
                            } else {
                                heartRates.append(filteredToDay.isEmpty ? filteredToDay.last?.data ?? 0.0 : average(numbers: filteredToDay.map{$0.data}))
                                
                                
                               // oRates.append(filteredToDayR.isEmpty ? filteredToDayR.last?.data ?? 0.0 : average(numbers: filteredToDayR.map{$0.data}))
                            }
                        
                            
                    dates.append(filteredToDay.last?.date ?? Date())
                        }
                    
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
               print(averageHRPerNight)
                    //if !averageHRPerNight.isEmpty {
                        if !averageHRPerNight.indices.contains(1) {
                medianHeartrate = averageHRPerNight.median()
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
                if averageHRPerNight.count > 20 {
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
                
                
                
            let filteredToNight = healthData.filter {
                return ($0.date.get(.hour) > bedTime && $0.date.get(.hour) < 24) || ($0.date.get(.hour) > 0 && $0.date.get(.hour) < wakeUpTime)
            }
               
            let filteredToHeartRate = filteredToNight.filter {
                return $0.title == HKQuantityTypeIdentifier.heartRate.rawValue
            }
               
            let filteredToSteps = filteredToNight.filter {
                return $0.title == HKQuantityTypeIdentifier.stepCount.rawValue
            }
                let filteredToR = filteredToNight.filter {
                    return $0.title == HKQuantityTypeIdentifier.respiratoryRate.rawValue
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
                if !filteredToMoreThanZeroSteps.map({$0.date.get(.hour)}).contains((filteredToDay.last?.date ?? Date()).get(.hour)) {
                    if filteredToR.map({$0.date.get(.hour)}).contains((filteredToDay.last?.date ?? Date()).get(.hour)) {
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
                
            }
                }
              //  if !heartRates.isEmpty {
                    let average = average(numbers: heartRates)
                if !average.isNaN {
                averageHRPerNight.append(average)
                }
            }
            }
           print("averageHRPerNight")
           print(averageHRPerNight)
              
                for night in averageHRPerNight {
                    #warning("exclude the night I am calculating the risk for from the overall medianHeartrate to ensure accuracy")
                    if !averageHRPerNight.isEmpty {
                        
                        medianHeartrate = averageHRPerNight.filter {$0 != night}.median()
                        print(averageHRPerNight.filter {$0 != night})
                    }
                    
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

