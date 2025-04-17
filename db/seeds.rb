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

# Categories for our articles
categories = ['Technology', 'Science', 'Health', 'Business', 'Entertainment', 'Sports']

# Authors for our articles
authors = ['John Doe', 'Jane Smith', 'Robert Johnson', 'Emily Davis']

# Article titles and content for more realistic data
articles = [
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
  }
]

# Create the 12 articles
articles.each_with_index do |article_data, index|
  Article.create!(
    title: article_data[:title],
    content: article_data[:content],
    author: authors[index % authors.length],
    category: article_data[:category]
  )
end

puts "Created #{Article.count} articles"
