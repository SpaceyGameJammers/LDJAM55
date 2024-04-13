extends CustomerWorkstation

func serve():
	super.serve()
	ResourceManager.add_money(4)
