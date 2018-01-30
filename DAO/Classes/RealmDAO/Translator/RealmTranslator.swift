//
//  RealmTranslator.swift
//  DAO
//
//  Created by Igor Bulyga on 04.02.16.
//  Copyright © 2016 RedMadRobot LLC. All rights reserved.
//


import Foundation
import RealmSwift


open class RealmTranslator<Model: RMREntity, RealmModel: RLMEntry> {
    
    public required init() {}
    
    
    open func fill(_ entry: RealmModel, fromEntity: Model) {
        fatalError("Abstract method")
    }


    open func fill(_ entity: Model, fromEntry: RealmModel) {
        fatalError("Abstract method")
    }

    
    /// All properties of entities will be overridden by entries properties.
    /// If entry doesn't exist, it'll be created.
    ///
    /// - Parameters:
    ///   - entries: list of instances of `RealmModel` type.
    ///   - fromEntities: array of instances of `Model` type.
    open func fill(_ entries: List<RealmModel>, fromEntities: [Model]) {
        var newEntries = [RealmModel]()
        
        fromEntities
            .map { entity -> (RealmModel, Model) in
                
                let entry = entries
                    .filter { $0.entryId == entity.entityId }
                    .first
                
                if let entry = entry {
                    return (entry, entity)
                } else {
                    let entry = RealmModel()
                    newEntries.append(entry)
                    return (entry, entity)
                }
            }
            .forEach {
                self.fill($0.0, fromEntity: $0.1)
        }
        
        if fromEntities.count < entries.count {
            let entityIds = fromEntities.map { $0.entityId }
            let deletedEntriesIndexes = entries
                .filter { !entityIds.contains($0.entryId) }
            deletedEntriesIndexes.forEach {
                if let index = entries.index(of: $0) {
                    entries.remove(at: index)
                }
            }
        } else {
            entries.append(objectsIn: newEntries)
        }
    }

    
    /// All properties of entries will be overridden by entities properties.
    ///
    /// - Parameters:
    ///   - entities: array of instances of `Model` type.
    ///   - fromEntries: list of instances of `RealmModel` type.
    open func fill( _ entities: inout [Model], fromEntries: List<RealmModel>) {
        entities.removeAll()
        
        fromEntries.forEach {
            let model = Model()
            entities.append(model)
            self.fill(model, fromEntry: $0)
        }
    }
    
}
