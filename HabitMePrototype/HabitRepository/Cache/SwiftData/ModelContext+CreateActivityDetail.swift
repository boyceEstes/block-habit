//
//  ModelContext+CreateActivityDetail.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 2/13/24.
//
import Foundation
import SwiftData


extension ModelContext {
    
    func createActivityDetail(
        name: String,
        valueType: ActivityDetailType,
        units: String?,
        calculationType: ActivityDetailCalculationType,
        overrideDuplicateNameError: Bool = false
    ) throws {
        
        let creationDate = Date()
        let unitsArray = units != nil && valueType == .number ? [units!] : []
        var newName = name
        
        // Check all the current ones - and update the name if there are duplicates
        let fetchDescriptor = FetchDescriptor<DataActivityDetail>()
        
        do {
            
            let activityDetails = try self.fetch(fetchDescriptor)
            
            if activityDetails.contains(where: { activityDetail in
                activityDetail.name == name && activityDetail.valueType == valueType
            }) {
                if !overrideDuplicateNameError {
                    throw BJRepositoryError.activityDetailNameAlreadyExists
                } else {
                    newName = makeNewName(closeTo: name, valueType: valueType, activityDetails: activityDetails)
                }
            }
            
            
            let activityDetail = DataActivityDetail(
                name: newName,
                valueType: valueType,
                availableUnits: unitsArray,
                isArchived: false,
                creationDate: creationDate,
                calculationType: calculationType,
                detailRecords: [],
                habits: []
            )
            
            self.insert(activityDetail)
            
        } catch {
            throw BJRepositoryError.failedToLoadActivityDetails
        }
    }
    
    
    func makeNewName(closeTo name: String, valueType: ActivityDetailType, activityDetails: [DataActivityDetail]) -> String {
        
        var duplicationNumber = 1
        var newName = "\(name) (\(duplicationNumber))"
        
        while activityDetails.contains(where: { activityDetail in
            activityDetail.name == newName && activityDetail.valueType == valueType
        }) {
            duplicationNumber += 1
            newName = "\(name) (\(duplicationNumber))"
        }
        
        return newName
    }
}


/*
 
 Lets say that I have a shepheard text and a shepheard number, I want those to both be unique

 So I try to create a new sheheard number. It should see that it does not contain it and create it
 
 However if it does contain sheheard number we will go to the make new name
 
 When we loop through sheheard new name we could see that we have shepheard (1) but if it is a text, then it doesn't apply
 
 So we want to return the (1) (assuming there was no (1) number, only a text)
 
 */
