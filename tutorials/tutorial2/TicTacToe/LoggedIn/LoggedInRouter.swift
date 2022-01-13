//
//  LoggedInRouter.swift
//  TicTacToe
//
//  Created by 60105116 on 2022/01/13.
//  Copyright © 2022 Uber. All rights reserved.
//

import RIBs

protocol LoggedInInteractable: Interactable, OffGameListener, TicTacToeListener {
    var router: LoggedInRouting? { get set }
    var listener: LoggedInListener? { get set }
}

protocol LoggedInViewControllable: ViewControllable {
    func present(viewController: ViewControllable)
    func dismiss(viewController: ViewControllable)
}

final class LoggedInRouter: Router<LoggedInInteractable>, LoggedInRouting {
    
    // TODO: Constructor inject child builder protocols to allow building children.
    init(interactor: LoggedInInteractable,
         viewController: LoggedInViewControllable,
         offGameBuilder: OffGameBuildable,
         tictactoeBuilder: TicTacToeBuildable) {
        
        self.viewController = viewController
        self.offGameBuilder = offGameBuilder
        self.ticTacToeBuilder = tictactoeBuilder
        
        super.init(interactor: interactor)
        interactor.router = self
    }
    
    func cleanupViews() {
        if let currentChild = currentChild {
            viewController.dismiss(viewController: currentChild.viewControllable)
        }
    }
    
    func routeToTicTacToe() {
        detachCurrentChild()
        attachTicTacToe()
    }
    
    func routeToOffGame() {
        detachCurrentChild()
        attachOffGame()
    }
    
    // MARK: - Private
    
    private let viewController: LoggedInViewControllable
    private let offGameBuilder: OffGameBuildable
    private let ticTacToeBuilder: TicTacToeBuildable
    private var currentChild: ViewableRouting?
    
    private func attachTicTacToe() {
        let tictactoe = ticTacToeBuilder.build(withListener: interactor)
        self.currentChild = tictactoe
        attachChild(tictactoe)
        viewController.present(viewController: tictactoe.viewControllable)
    }
    
    private func attachOffGame() {
        let offGame = offGameBuilder.build(withListener: interactor)
        self.currentChild = offGame
        attachChild(offGame)
        viewController.present(viewController: offGame.viewControllable)
    
    }
    
    private func detachCurrentChild() {
        if let currentChild = currentChild {
            detachChild(currentChild)
            viewController.dismiss(viewController: currentChild.viewControllable)
            self.currentChild = nil
        }
    }
    
    override func didLoad() {
        super.didLoad()
        attachOffGame()
    }
}
