//
//  LoggedInBuilder.swift
//  TicTacToe
//
//  Created by 60105116 on 2022/01/13.
//  Copyright © 2022 Uber. All rights reserved.
//

import RIBs

protocol LoggedInDependency: Dependency {
    var loggedInViewController: LoggedInViewControllable { get }
}

final class LoggedInComponent: Component<LoggedInDependency>, OffGameDependency, TicTacToeDependency {
    
    fileprivate var loggedInViewController: LoggedInViewControllable {
        return dependency.loggedInViewController
    }
}

// MARK: - Builder
protocol LoggedInBuildable: Buildable {
    func build(withListener listener: LoggedInListener) -> LoggedInRouting
}

final class LoggedInBuilder: Builder<LoggedInDependency>, LoggedInBuildable {
    
    override init(dependency: LoggedInDependency) {
        super.init(dependency: dependency)
    }
    
    func build(withListener listener: LoggedInListener) -> LoggedInRouting {
        let component = LoggedInComponent(dependency: dependency)
        let interactor = LoggedInInteractor()
        interactor.listener = listener
        
        let offGameBuilder = OffGameBuilder(dependency: component)
        let tictactoeBuilder = TicTacToeBuilder(dependency: component)
        
        return LoggedInRouter(interactor: interactor,
                              viewController: component.loggedInViewController,
                              offGameBuilder: offGameBuilder,
                              tictactoeBuilder: tictactoeBuilder)
    }
}
