require 'chunky_png'
class Handwriting
	@@three = Hash.new
	@@five = Hash.new
	@@eight = Hash.new

	def initialize
		threeFilenames = ['number3_1.png', 'number3_2.png', 'number3_3.png', 'number3_4.png', 'number3_5.png', 'number3_6.png', 'number3_7.png', 'number3_8.png', 'number3_9.png', 'number3_10.png']
		fiveFilenames = ['number5_1.png', 'number5_2.png', 'number5_3.png', 'number5_4.png', 'number5_5.png', 'number5_6.png', 'number5_7.png', 'number5_8.png', 'number5_9.png', 'number5_10.png']
		eightFilenames = ['number8_1.png', 'number8_2.png', 'number8_3.png', 'number8_4.png', 'number8_5.png', 'number8_6.png', 'number8_7.png', 'number8_8.png', 'number8_9.png', 'number8_10.png']
		
		@@three = constructMap(threeFilenames)
		@@five = constructMap(fiveFilenames)
		@@eight = constructMap(eightFilenames)

		trainUntilStable(threeFilenames, fiveFilenames, eightFilenames)

		#uncomment below to generate the images
		#generateWeightImage(@@three, "Weight image for '3' with a three node hidden layer.png")
		#generateWeightImage(@@five, "Weight image for '5' with a three node hidden layer.png")
		#generateWeightImage(@@eight, "Weight image for '8' with a three node hidden layer.png")
	end
		
	def constructMap (filenames)
		Hash thisHash = Hash.new
		(0...784).each do |i|
			thisHash[i] = 0
		end
		filenames.each do |filename|
			image = ChunkyPNG::Image.from_file(filename)			
			(0...image.dimension.height).each do |y|
	  			(0...image.dimension.width).each do |x|
	    			r = ChunkyPNG::Color.r(image[x,y])
	    			location = (image.dimension.width * y) + x
	    			if r > 0
	    				thisHash[location] = thisHash[location] + 1
	    			end
	    		end
	    	end
	    end
	    return thisHash
    end

    def trainUntilStable(threeFilenames, fiveFilenames, eightFilenames)
		tempThree = Hash.new
		tempFive = Hash.new
		tempEight = Hash.new

		while (tempThree != @@three && tempFive != @@five && tempEight != @@eight)
			tempThree = @@three.clone 
			tempFive = @@five.clone
			tempEight = @@eight.clone

			threeFilenames.each do |filename|
				train(filename, 3)
			end		

			fiveFilenames.each do |filename|
				train(filename, 5)
			end		
		
			eightFilenames.each do |filename|
				train(filename, 8)
			end

			threeFilenames.each do |filename|
				train(filename, 3)
			end		

			fiveFilenames.each do |filename|
				train(filename, 5)
			end		
		
			eightFilenames.each do |filename|
				train(filename, 8)
			end			
		end
	end

	def train filename, expected
		image = ChunkyPNG::Image.from_file(filename)
		threeScore = fiveScore = eightScore = 0
		(0...image.dimension.height).each do |y|
	  		(0...image.dimension.width).each do |x|
	    		r = ChunkyPNG::Color.r(image[x,y])
	    		location = (image.dimension.width * y) + x
	    		if r > 0
	    			threeScore += @@three[location]
	    			fiveScore += @@five[location]
					eightScore += @@eight[location]
	    		end
	    	end
	    end
	    if threeScore >= fiveScore && threeScore >= eightScore	    	
	    	if expected != 3
	    		backpropagate(filename, expected)
	    	end
	    elsif fiveScore >= eightScore
	    	if expected != 5
	    		backpropagate(filename, expected)
	    	end
	    else
	    	if expected != 8
	    		backpropagate(filename, expected)
	    	end
	    end
	end

	def backpropagate filename, expected
		if expected == 3
			addToMap 3, filename
			train filename, 3
		elsif expected == 5
			addToMap 5, filename
			train filename, 5
		else
			addToMap 8, filename
			train filename, 8
		end
	end	

    def addToMap (thisHashNum, filename)
		if thisHashNum == 3
			thisHash = @@three
		elsif thisHashNum == 5
			thisHash = @@five
		else
			thisHash = @@eight
		end
		image = ChunkyPNG::Image.from_file(filename)			
		(0...image.dimension.height).each do |y|
  			(0...image.dimension.width).each do |x|
    			r = ChunkyPNG::Color.r(image[x,y])
    			location = (image.dimension.width * y) + x
    			if r > 0
    				thisHash[location] = thisHash[location] + 1
    			end
    		end
    	end
    end

    def analyze(*filenames)
    	filenames.each do |filename|
	    	image = ChunkyPNG::Image.from_file(filename)
			threeScore = fiveScore = eightScore = 0
			(0...image.dimension.height).each do |y|
		  		(0...image.dimension.width).each do |x|
		    		r = ChunkyPNG::Color.r(image[x,y])
		    		location = (image.dimension.width * y) + x
		    		if r > 0
		    			threeScore += @@three[location]
		    			fiveScore += @@five[location]
						eightScore += @@eight[location]
		    		end
		    	end
		    end		    

		    if threeScore >= fiveScore && threeScore >= eightScore	    	
		    	puts "It's a three"
		    elsif fiveScore >= eightScore
		    	puts "It's a five"
		    else
		    	puts "It's an eight"
		    end
		end
	end

    def generateWeightImage hashmap, filename
    	maxWeight = 0
    	hashmap.each do |k, v|
    		if v > maxWeight
    			maxWeight = v
    		end
    	end
    	colorInterval = 255/maxWeight
    	image = ChunkyPNG::Image.new(28, 28, ChunkyPNG::Color::TRANSPARENT)
    	(0...image.dimension.height).each do |y|
	  		(0...image.dimension.width).each do |x|
	  			location = (image.dimension.width * y) + x
	  			weight = hashmap[location]
	  			color = weight*colorInterval
	  			image[x,y] = ChunkyPNG::Color.rgba(color,color,color,255)
	  		end
	  	end
	  	image.save(filename, :interlace => true)
    end
end

c = Handwriting.new
#To run against a test set, uncomment the following line and replace the *filenames arg with the paths to the test files
#c.analyze(*filenames)