extends Node

signal update_rating(procentage: float)
signal update_money(amount: int)
signal update_suss(procentage: float)
signal update_meat(amount: int)
signal update_fish(amount: int)
signal update_carrots(amount: int)
signal update_potatoes(amount: int)
signal update_wine(amount: int)

var rating_score: int = 0
var number_of_ratings: int = 0
var rating: float = 0.5
var money: int = 0
var suss: float = 0.25
var meat: int = 0
var fish: int = 0
var carrots: int = 0
var potatoes: int = 0
var wine: int = 0

func change_money(amount:int):
	money += amount
	update_money.emit(money)

func change_meat(amount:int):
	meat += amount
	update_potatoes.emit(potatoes)

func change_fish(amount:int):
	fish += amount
	update_fish.emit(fish)

func change_carrots(amount:int):
	carrots += amount
	update_carrots.emit(carrots)

func change_potatoes(amount:int):
	potatoes += amount
	update_potatoes.emit(potatoes)

func change_wine(amount:int):
	wine += amount
	update_wine.emit(wine)

func change_rating(score:int):
	rating_score += score
	number_of_ratings += 1
	rating = (rating_score as float) / (number_of_ratings as float)
	update_rating.emit(rating)

func change_suss(score:float):
	suss += score
	update_suss.emit(suss)

func get_money():
	return money

func get_meat():
	return meat

func get_fish():
	return fish

func get_carrots():
	return carrots

func get_potatoes():
	return potatoes

func get_wine():
	return wine

func get_rating():
	return rating

func get_suss():
	return suss


