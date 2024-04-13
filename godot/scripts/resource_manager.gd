extends Node

signal money_update(amount)

var money: int = 0

func add_money(amount:int):
	money += amount
	money_update.emit(money)
