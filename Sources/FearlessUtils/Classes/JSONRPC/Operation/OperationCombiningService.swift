import Foundation
import RobinHood

public enum OperationCombiningServiceError: Error {
    case alreadyRunningOrFinished
}

public final class OperationCombiningService<T>: Longrunable {
    public  enum State {
        case waiting
        case running
        case finished
    }

    public typealias ResultType = [T]

    public let operationsClosure: () throws -> [CompoundOperationWrapper<T>]
    public let operationManager: OperationManagerProtocol
    public  let operationsPerBatch: Int

    private(set) var state: State = .waiting

    private var wrappers: [CompoundOperationWrapper<T>]?

    public  init(
        operationManager: OperationManagerProtocol,
        operationsPerBatch: Int = 0,
        operationsClosure: @escaping () throws -> [CompoundOperationWrapper<T>]
    ) {
        self.operationManager = operationManager
        self.operationsClosure = operationsClosure
        self.operationsPerBatch = operationsPerBatch
    }

    public func start(with completionClosure: @escaping (Result<ResultType, Error>) -> Void) {
        guard state == .waiting else {
            completionClosure(.failure(OperationCombiningServiceError.alreadyRunningOrFinished))
            return
        }

        state = .waiting

        do {
            let wrappers = try operationsClosure()

            if operationsPerBatch > 0, wrappers.count > operationsPerBatch {
                for index in operationsPerBatch ..< wrappers.count {
                    let prevBatchIndex = index / operationsPerBatch - 1

                    let prevStart = prevBatchIndex * operationsPerBatch
                    let prevEnd = (prevBatchIndex + 1) * operationsPerBatch

                    for prevIndex in prevStart ..< prevEnd {
                        wrappers[index].addDependency(wrapper: wrappers[prevIndex])
                    }
                }
            }

            let mapOperation = ClosureOperation<ResultType> {
                try wrappers.map { try $0.targetOperation.extractNoCancellableResultData() }
            }

            mapOperation.completionBlock = { [weak self] in
                self?.state = .finished
                self?.wrappers = nil

                do {
                    let result = try mapOperation.extractNoCancellableResultData()
                    completionClosure(.success(result))
                } catch {
                    completionClosure(.failure(error))
                }
            }

            let dependencies = wrappers.flatMap(\.allOperations)
            dependencies.forEach { mapOperation.addDependency($0) }

            operationManager.enqueue(operations: dependencies + [mapOperation], in: .transient)

        } catch {
            completionClosure(.failure(error))
        }
    }

    public func cancel() {
        if state == .running {
            wrappers?.forEach { $0.cancel() }
            wrappers = nil
        }

        state = .finished
    }
}

public extension OperationCombiningService {
    func longrunOperation() -> LongrunOperation<[T]> {
        LongrunOperation(longrun: AnyLongrun(longrun: self))
    }
}
