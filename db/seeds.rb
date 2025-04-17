# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Clear existing data
Article.destroy_all

# Only seed if there are no articles
if Article.count == 0
  puts "No articles found. Seeding database with sample articles..."
  
  # Categories for our articles
  categories = ['Technology', 'Science', 'Health', 'Business', 'Entertainment', 'Sports', 'Travel', 'Food', 'Fashion', 'Education']
  
  # Authors for our articles
  authors = ['John Doe', 'Jane Smith', 'Robert Johnson', 'Emily Davis', 'Michael Wilson', 'Sophia Garcia', 'David Martinez', 'Olivia Taylor', 'James Brown', 'Emma Miller']
  
  # Article titles and content for more realistic data
  articles = [
    # Original 12 articles
    {
      title: "The Future of Artificial Intelligence",
      content: "Artificial intelligence continues to evolve at a rapid pace. Recent advancements in machine learning algorithms have enabled systems to perform tasks that were once thought to be exclusively human.\n\nDeep learning models now power everything from voice assistants to medical diagnosis tools. As these technologies improve, we're seeing AI applications expand into new domains.\n\nHowever, ethical considerations remain at the forefront of AI development. Questions about bias, transparency, and accountability must be addressed as these systems become more integrated into our daily lives.",
      category: "Technology"
    },
    {
      title: "Climate Change: The Latest Research",
      content: "New research indicates that global temperatures are rising faster than previously predicted. Scientists have observed accelerated ice melt in polar regions, contributing to rising sea levels worldwide.\n\nThe impact on ecosystems has been profound, with many species struggling to adapt to rapidly changing conditions. Coral reefs, in particular, are experiencing unprecedented bleaching events due to ocean warming.\n\nDespite these alarming trends, advances in renewable energy technology offer some hope. Solar and wind power costs continue to decline, making green energy alternatives increasingly viable for widespread adoption.",
      category: "Science"
    },
    {
      title: "Wellness Trends for 2025",
      content: "Health experts are seeing a shift toward holistic wellness approaches that combine physical, mental, and social health strategies. The integration of technology with traditional wellness practices has created new opportunities for personalized health management.\n\nMental health awareness continues to grow, with more employers implementing programs to support employee wellbeing. Digital detox retreats have also gained popularity as people seek balance in an increasingly connected world.\n\nNutritional science is evolving as well, with a focus on personalized diet plans based on individual metabolic responses and genetic profiles.",
      category: "Health"
    },
    {
      title: "Emerging Markets: Investment Opportunities",
      content: "Economic analysts point to several emerging markets showing strong growth potential despite global uncertainties. Countries with young populations and developing digital infrastructure are particularly attractive to forward-thinking investors.\n\nThe expansion of mobile banking has created new financial ecosystems in regions previously underserved by traditional banking. This has opened doors for innovative fintech solutions and microfinance initiatives.\n\nHowever, political stability and regulatory frameworks remain key considerations for those looking to capitalize on these growing markets.",
      category: "Business"
    },
    {
      title: "Cinema's Digital Revolution",
      content: "The film industry continues to undergo transformation as streaming platforms redefine content creation and distribution. Traditional studios are adapting to changing viewer habits with hybrid release strategies.\n\nVirtual production techniques, popularized by shows like 'The Mandalorian,' are becoming industry standards. These approaches combine real-time rendering with physical sets to create immersive environments without location shooting.\n\nMeanwhile, independent filmmakers are finding new avenues for reaching audiences through online platforms that bypass traditional gatekeepers.",
      category: "Entertainment"
    },
    {
      title: "The Evolution of Team Sports",
      content: "Professional sports leagues are embracing data analytics to enhance player performance and strategic decision-making. Advanced metrics have become essential tools for talent evaluation and game planning across all major sports.\n\nFan engagement has also evolved, with augmented reality experiences and interactive content becoming standard features at sporting events and through broadcast media.\n\nAt the same time, concerns about player health have led to rule changes and improved monitoring systems designed to reduce injuries while maintaining competitive intensity.",
      category: "Sports"
    },
    {
      title: "Sustainable Urban Development",
      content: "Cities around the world are implementing innovative approaches to sustainability, from green infrastructure to smart city technologies. Urban planners are prioritizing walkability, public transportation, and mixed-use development to reduce carbon footprints.\n\nGreen building standards continue to evolve, with new materials and design principles that minimize environmental impact while enhancing occupant wellbeing. Vertical gardens and urban farms are becoming common features in municipal planning.\n\nCommunity involvement has proven crucial to successful sustainability initiatives, with citizen science projects and participatory budgeting processes gaining popularity.",
      category: "Science"
    },
    {
      title: "Next-Generation Mobile Technology",
      content: "The rollout of advanced mobile networks is enabling a new wave of connected devices and services. Beyond faster download speeds, these networks offer reduced latency and improved reliability for critical applications.\n\nEdge computing infrastructure is developing alongside these networks, allowing data processing to occur closer to the point of collection. This architecture is essential for time-sensitive applications like autonomous vehicles and industrial automation.\n\nPrivacy concerns remain significant as more devices connect to networks and collect user data, prompting new approaches to security and data governance.",
      category: "Technology"
    },
    {
      title: "Preventative Healthcare Innovations",
      content: "Medical researchers are making significant progress in early disease detection through advanced screening technologies. AI-powered diagnostic tools can now identify potential health issues before symptoms appear, enabling earlier intervention.\n\nGenetic testing has become more accessible, providing individuals with insights about potential health risks and informing preventative strategies. Personalized health plans based on genetic profiles are increasingly common.\n\nLifestyle medicine approaches that focus on nutrition, exercise, and stress management are gaining recognition in mainstream healthcare as effective ways to prevent chronic conditions.",
      category: "Health"
    },
    {
      title: "Digital Currency Adoption",
      content: "Central banks and financial institutions are exploring digital currencies as alternatives or supplements to traditional money. These initiatives aim to combine the convenience of digital transactions with the stability of regulated currencies.\n\nBlockchain technology continues to mature, offering solutions for secure, transparent transactions across various sectors. Smart contracts are streamlining complex business processes by automating agreement enforcement.\n\nRegulatory frameworks are evolving to address the unique challenges posed by cryptocurrencies and decentralized finance, seeking to balance innovation with consumer protection.",
      category: "Business"
    },
    {
      title: "Virtual Reality Entertainment",
      content: "The entertainment industry is embracing virtual reality as a new medium for storytelling and audience engagement. Immersive experiences now range from interactive narratives to virtual concerts and sporting events.\n\nTechnology improvements have addressed earlier limitations, with higher-resolution displays and more intuitive controls making VR more accessible to mainstream audiences. Wireless headsets have removed mobility constraints that limited adoption.\n\nContent creators are developing new techniques specific to virtual environments, moving beyond adaptations of traditional media to create experiences unique to the medium.",
      category: "Entertainment"
    },
    {
      title: "Training Science Breakthroughs",
      content: "Sports scientists have developed new approaches to athletic training that optimize performance while reducing injury risk. Personalized recovery protocols based on biometric data are replacing one-size-fits-all training regimens.\n\nNutritional timing and composition are receiving increased attention, with athletes using precise fueling strategies for different training phases. Hydration and electrolyte management have become highly customized.\n\nMental performance training is now considered as important as physical conditioning, with visualization techniques and psychological resilience training integrated into athlete development programs.",
      category: "Sports"
    },
    
    # Additional 18 articles for a total of 30
    {
      title: "The Hidden Gems of Southeast Asia",
      content: "Beyond the popular tourist destinations, Southeast Asia offers countless hidden treasures for adventurous travelers. From secluded beaches in the Philippines to ancient temples tucked away in the jungles of Cambodia, these lesser-known spots provide authentic experiences away from the crowds.\n\nLocal cuisine in these regions often features unique flavors and techniques that haven't been adapted for international palates. Culinary adventurers will discover dishes that rarely appear on restaurant menus abroad.\n\nCommunity-based tourism initiatives are making these hidden destinations more accessible while ensuring that tourist dollars benefit local economies directly.",
      category: "Travel"
    },
    {
      title: "Plant-Based Cooking Revolution",
      content: "Innovative chefs around the world are transforming plant-based cooking from a niche dietary choice to a culinary art form. Advanced techniques are creating plant-derived proteins with textures and flavors that closely mimic animal products.\n\nCultural food traditions from regions with long histories of vegetarian cooking are providing inspiration for modern plant-based cuisine. Indian, Ethiopian, and East Asian techniques are particularly influential in this evolving culinary landscape.\n\nRestaurants dedicated to sophisticated plant-based dining experiences have earned critical acclaim and Michelin stars, demonstrating that vegetable-focused cuisine can compete at the highest levels of gastronomy.",
      category: "Food"
    },
    {
      title: "Sustainable Fashion Innovations",
      content: "The fashion industry is embracing circular economy principles with new materials made from agricultural waste, recycled textiles, and even lab-grown alternatives to animal products. These innovations are reducing the environmental footprint of clothing production.\n\nDesigners are also exploring modular garment construction that allows for easy disassembly and recycling at the end of a product's life. Some brands now offer take-back programs that reward consumers for returning worn items.\n\nTransparency in supply chains has become a major focus, with blockchain technology enabling consumers to trace the journey of their garments from raw materials to finished products.",
      category: "Fashion"
    },
    {
      title: "Future of Higher Education",
      content: "Universities are reimagining the educational experience in response to technological change and evolving workforce needs. Hybrid learning models combine online flexibility with in-person collaboration, allowing students to customize their educational journeys.\n\nMicro-credentials and stackable certificates are providing alternatives to traditional degree programs, enabling continuous learning throughout careers. These shorter, focused educational experiences align closely with specific industry needs.\n\nGlobal collaboration between institutions is increasing, with students able to access courses and expertise from universities worldwide through digital platforms and exchange programs.",
      category: "Education"
    },
    {
      title: "Quantum Computing Breakthroughs",
      content: "Recent advances in quantum computing have brought this transformative technology closer to practical applications. Researchers have achieved quantum advantage in specific computational tasks, demonstrating capabilities beyond what classical computers can achieve.\n\nPotential applications span from materials science to cryptography, with quantum simulations potentially accelerating drug discovery and the development of new catalysts. Financial modeling and optimization problems are also promising areas for early quantum applications.\n\nHowever, significant engineering challenges remain in scaling quantum systems and reducing error rates. The race to build fault-tolerant quantum computers continues across academic and industry research teams.",
      category: "Technology"
    },
    {
      title: "Ocean Conservation Innovations",
      content: "New approaches to marine conservation are combining traditional protection methods with advanced technology and community engagement. Autonomous underwater vehicles now monitor marine protected areas, collecting data on ecosystem health and illegal fishing activities.\n\nRestorative ocean farming, which cultivates seaweed and shellfish without requiring inputs like fertilizer or fresh water, is emerging as a sustainable food production model that actually improves marine environments.\n\nCoastal communities are becoming central to conservation efforts, with indigenous knowledge informing scientific approaches to managing marine resources sustainably.",
      category: "Science"
    },
    {
      title: "Precision Medicine Advances",
      content: "Healthcare is becoming increasingly personalized as genetic sequencing becomes more affordable and accessible. Treatment protocols are being tailored to individual genetic profiles, improving efficacy and reducing side effects.\n\nDigital biomarkers collected through wearable devices are providing continuous health monitoring beyond periodic clinical visits. This real-time data enables earlier interventions and more precise management of chronic conditions.\n\nArtificial intelligence systems are helping clinicians interpret complex medical data, identifying patterns that might otherwise go unnoticed and suggesting personalized treatment approaches based on similar patient outcomes.",
      category: "Health"
    },
    {
      title: "The Future of Remote Work",
      content: "Companies are developing sophisticated approaches to hybrid work that balance flexibility with collaboration. Office spaces are being redesigned as collaboration hubs rather than daily work locations, with technology enabling seamless integration of remote and in-person participants.\n\nDigital nomad visas offered by various countries are allowing knowledge workers to live and work internationally, creating new patterns of global mobility and challenging traditional concepts of workplace geography.\n\nHR policies are evolving to address the unique challenges of distributed teams, with new approaches to performance evaluation, team building, and workplace culture in virtual environments.",
      category: "Business"
    },
    {
      title: "Interactive Storytelling Platforms",
      content: "Entertainment is becoming increasingly participatory as new technologies enable audiences to influence and shape narratives. Interactive streaming content allows viewers to make decisions that affect character choices and plot directions.\n\nAugmented reality experiences are overlaying story elements onto physical environments, blending fictional narratives with real-world settings for immersive entertainment experiences accessible through mobile devices.\n\nAI-generated content is enabling personalized stories that adapt to individual preferences and choices, creating unique narrative experiences for each participant while maintaining overall story coherence.",
      category: "Entertainment"
    },
    {
      title: "Esports Goes Mainstream",
      content: "Competitive gaming has evolved into a global phenomenon with professional leagues, substantial prize pools, and dedicated venues. Traditional sports organizations are establishing esports divisions, recognizing the growing overlap between digital and conventional sports audiences.\n\nBroadcast production values have risen to match traditional sports, with sophisticated commentary, player profiles, and statistical analysis enhancing the viewing experience for millions of fans worldwide.\n\nEducational institutions are now offering esports scholarships and developing academic programs around game design, team management, and the business aspects of competitive gaming.",
      category: "Sports"
    },
    {
      title: "Sustainable Tourism Initiatives",
      content: "The travel industry is addressing environmental concerns with innovative approaches to sustainable tourism. Carbon offset programs and emission-reduction strategies are becoming standard features of responsible travel offerings.\n\nRegeneration rather than mere conservation is the new focus, with tourism operations actively contributing to ecosystem restoration and community development in destination areas.\n\nTechnology is enabling more precise measurement of tourism's environmental impact, allowing travelers to make informed choices and incentivizing businesses to improve their sustainability practices.",
      category: "Travel"
    },
    {
      title: "Fermentation Renaissance",
      content: "Ancient fermentation techniques are experiencing a revival, with chefs and food producers exploring traditional preservation methods from cultures worldwide. Beyond familiar products like yogurt and kimchi, lesser-known fermented foods are entering mainstream culinary awareness.\n\nScientific understanding of the microbiome is informing modern approaches to fermentation, with precise control of bacterial cultures creating consistent and safe products with complex flavor profiles.\n\nCraft producers are creating artisanal fermented goods using local ingredients and traditional methods, connecting consumers with regional food heritage and sustainable production practices.",
      category: "Food"
    },
    {
      title: "Adaptive Clothing Innovations",
      content: "Fashion designers are creating stylish adaptive clothing that addresses the needs of people with disabilities without sacrificing aesthetic appeal. Magnetic closures, adjustable seams, and sensory-friendly fabrics are being incorporated into mainstream fashion collections.\n\nVirtual fitting technologies are making shopping more accessible, allowing customers to visualize how garments will look and function without physical try-ons. Custom adjustments can be specified digitally before production.\n\nInclusive design approaches are bringing diverse perspectives into the fashion creation process, resulting in clothing that works better for all body types and physical abilities.",
      category: "Fashion"
    },
    {
      title: "Personalized Learning Platforms",
      content: "Educational technology is enabling truly individualized learning experiences through adaptive systems that respond to student progress and preferences. AI-powered platforms adjust content difficulty, presentation style, and pacing based on ongoing assessment of student performance.\n\nLearning analytics provide educators with detailed insights into student engagement and comprehension, enabling timely interventions and support. These tools help identify concepts that may require additional explanation or alternative teaching approaches.\n\nGamification elements integrated into educational software maintain motivation through achievement systems and progress visualization, making the learning process more engaging and rewarding.",
      category: "Education"
    },
    {
      title: "The Rise of Voice Computing",
      content: "Voice interfaces are becoming increasingly sophisticated, moving beyond simple commands to natural conversations with digital assistants. Contextual understanding and memory of previous interactions are creating more fluid and useful voice experiences.\n\nMultilingual capabilities have improved dramatically, with real-time translation features breaking down language barriers in both personal and professional contexts. Voice systems now recognize and adapt to diverse accents and speech patterns.\n\nPrivacy-focused voice processing is addressing security concerns, with more computation happening on devices rather than in the cloud. User control over recording and data usage has become a key differentiator among voice platforms.",
      category: "Technology"
    },
    {
      title: "Renewable Energy Breakthroughs",
      content: "Advanced energy storage technologies are solving intermittency challenges for solar and wind power, making renewable energy more reliable for grid-scale applications. Flow batteries, gravity-based storage, and green hydrogen are complementing traditional lithium-ion batteries.\n\nFloating solar installations and offshore wind farms are utilizing water surfaces for energy generation, avoiding land use conflicts and accessing stronger, more consistent wind resources in marine environments.\n\nDistributed energy systems with local microgrids are increasing resilience and providing power to remote communities, combining renewable generation with smart management systems that optimize energy distribution.",
      category: "Science"
    },
    {
      title: "Sleep Science Innovations",
      content: "Research into sleep quality has led to new approaches for improving this fundamental aspect of health. Smart mattresses and bedding with embedded sensors now track sleep phases and environmental factors, providing personalized recommendations for better rest.\n\nChrono-nutrition, which aligns meal timing with circadian rhythms, is showing promise for enhancing sleep quality and overall metabolic health. Dietary choices and eating schedules are being recognized as important factors in sleep regulation.\n\nCognitive techniques for addressing insomnia are becoming more accessible through digital platforms, offering evidence-based interventions without the side effects associated with sleep medications.",
      category: "Health"
    },
    {
      title: "Circular Economy Business Models",
      content: "Companies are reimagining their operations around principles of regeneration and reuse, moving beyond the traditional take-make-waste approach. Product-as-a-service models are extending manufacturer responsibility throughout the product lifecycle, incentivizing durability and repairability.\n\nReverse logistics systems are becoming more sophisticated, enabling efficient collection and processing of used products for remanufacturing and recycling. Some retailers now offer buyback programs for their own products.\n\nMaterial passports that track the components and substances in products are facilitating future recycling and reuse, providing valuable information for end-of-life processing and compliance with evolving regulations.",
      category: "Business"
    }
  ]
  
  # Create the 30 articles
  articles.each_with_index do |article_data, index|
    Article.create!(
      title: article_data[:title],
      content: article_data[:content],
      author: authors[index % authors.length],
      category: article_data[:category]
    )
  end
  
  puts "Created #{Article.count} articles"
else
  puts "Database already contains #{Article.count} articles. Skipping seed data."
end
