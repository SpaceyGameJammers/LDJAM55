extends Node

signal update_rating(procentage: float)
signal update_money(amount: int)
signal update_suss(procentage: float)
signal update_meat(amount: int)
signal update_fish(amount: int)
signal update_carrots(amount: int)
signal update_potatoes(amount: int)
signal update_wine(amount: int)
signal update_plates(amount: int)
signal update_raw_meat(amount: int)
signal update_raw_fish(amount: int)
signal update_raw_carrots(amount: int)
signal update_raw_potatoes(amount: int)
signal update_dirty_plates(amount: int)

var rating_score: float = 0
var number_of_ratings: int = 0
var rating: float = 0.5
var money: int = 0
var suss: float = 0.25

var meat: int = 0
var fish: int = 0
var carrots: int = 0
var potatoes: int = 0
var plates: int = 10

var raw_meat: int = 10
var raw_fish: int = 10
var raw_carrots: int = 10
var raw_potatoes: int = 10
var dirty_plates: int = 0

var wine: int = 0

func refresh_resource():
	update_carrots.emit(carrots)
	update_fish.emit(fish)
	update_meat.emit(meat)
	update_potatoes.emit(potatoes)
	update_wine.emit(wine)
	update_plates.emit(plates)
	update_raw_carrots.emit(raw_carrots)
	update_raw_fish.emit(raw_fish)
	update_raw_meat.emit(raw_meat)
	update_raw_potatoes.emit(raw_potatoes)
	update_dirty_plates.emit(dirty_plates)

func assemble_food(MEAT:int, FISH:int, CARROTS:int, POTATOES:int, WINE:int):
	change_meat(-MEAT)
	change_fish(-FISH)
	change_carrots(-CARROTS)
	change_potatoes(-POTATOES)
	change_wine(-WINE)
	change_plates(-1)

func cook_meat(amount:int) -> bool:
	if raw_meat > 0:
		raw_meat -= amount
		update_raw_meat.emit(raw_meat)
		change_meat(amount)
		return true
	return false

func cook_fish(amount:int) -> bool:
	if raw_fish > 0:
		raw_fish -= amount
		update_raw_fish.emit(raw_fish)
		change_fish(amount)
		return true
	return false

func cook_carrots(amount:int) -> bool:
	if raw_carrots > 0:
		raw_carrots -= amount
		update_raw_carrots.emit(raw_carrots)
		change_carrots(amount)
		return true
	return false

func cook_potatoes(amount:int) -> bool:
	if raw_potatoes > 0:
		raw_potatoes -= amount
		update_raw_potatoes.emit(raw_potatoes)
		change_potatoes(amount)
		return true
	return false

func clean_plate(amount:int) -> bool:
	if dirty_plates > 0:
		dirty_plates -= amount
		update_dirty_plates.emit(dirty_plates)
		change_plates(amount)
		return true
	return false

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

func change_plates(amount:int):
	plates += amount
	update_plates.emit(plates)

func change_rating(score:float):
	rating_score += score
	number_of_ratings += 1
	rating = ((rating_score as float) / (number_of_ratings as float))
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
