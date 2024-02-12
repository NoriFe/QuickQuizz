require "open-uri"
class QuizzesController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @user = current_user
    @my_quiz_results = QuizResult.where(user: @user).order(created_at: :desc)
    @recently_created = request&.referer&.include?("new")
  end

  def show
    @quiz = Quiz.find(params[:id])
    # @user_input = params[:text]
  end

  def new
    @quiz = Quiz.new
  end

  def create
    prompt = "ruby on rails"

    # prompt = "The Solar System is made up of all the planets that orbit our Sun. In addition to planets, the Solar System also consists of moons, comets, asteroids, minor planets, dust and gas. The inner solar system contains the Sun, Mercury, Venus, Earth and Mars. The main asteroid belt lies between the orbits of Mars and Jupiter. The planets of the outer solar system are Jupiter, Saturn, Uranus and Neptune (Pluto is now classified as a dwarf planet)."






    @quiz = Quiz.new(quiz_params)
    @quiz.user = current_user
    if @quiz.save
      if @quiz.image.attached?
        temp = Tempfile.new ["image", ".jpg"], Rails.root.join('tmp')
        temp.binmode
        temp.write(URI.open(@quiz.image.url).read)
        temp.rewind
        image = RTesseract.new(temp.path)
        @quiz.text = image.to_s
      end
      chatoiasdgfh


      # redirect_to quiz_path(@quiz, text: @quiz.text)
      redirect_to quizzes_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def destroy
    @quiz = Quiz.find(params[:id])
    @quiz.destroy
    redirect_to quizzes_path, status: :see_other
  end

  private

  def quiz_params
    params.require(:quiz).permit(:image, :text)
  end


  def chatoiasdgfh
    client = OpenAI::Client.new
    chatgpt_response = client.chat(parameters: {
      model: "gpt-3.5-turbo-0125",
      messages: [{
        role: "system",
        content: "You are a helpful assistant that generates quiz questions based on the provided content. Respond with five short questions and four plausible options/ answers for each question, of which only one is correct. Provide your answer in a  JSON structure similar to this.
          [
            {
              'topic: '<The topic of the quiz>',
              'question': '<The quiz question you generate>',
              'options': {
                'option1': {'body': '<Plausible option 1>', 'isItCorrect': <true or false>},
                'option2': {'body': '<Plausible option 2>', 'isItCorrect': <true or false>},
                'option3': {'body': '<Plausible option 3>', 'isItCorrect': <true or false>},
                'option4': {'body': '<Plausible option 4>', 'isItCorrect': <true or false>}
              }
            },
            {
              'topic: '<The topic of the quiz>',
              'question': '<The quiz question you generate>',
              'options': {
                'option1': {'body': '<Plausible option 1>', 'isItCorrect': <true or false>},
                'option2': {'body': '<Plausible option 2>', 'isItCorrect': <true or false>},
                'option3': {'body': '<Plausible option 3>', 'isItCorrect': <true or false>},
                'option4': {'body': '<Plausible option 4>', 'isItCorrect': <true or false>}
              }
            }
          ]
          Under no circumstances use double quotes in your JSON response. Use single quotes instead. If you use double quotes, the JSON will be invalid and an error will occur. If you are unsure about the JSON structure, please refer to the example above."
      },
      {
        role: "user",
        content: "Generate a multiple choice quiz about: #{@quiz.text}. Give me only the text of the quiz, without any of your own answer like 'Here is a quiz I made'."
      },
      {
        role: "assistant",
        content: "{'topic': 'Premier League location', 'question': 'Where is the Premier League played?',
        'options': {'option1': {'body': 'France', 'isItCorrect': false}, 'option2': {'body': 'England', 'isItCorrect': true}, 'option3': {'body': 'Sweden', 'isItCorrect': false}}}"
      }]
    })

    # @content = chatgpt_response["choices"][0]["message"]["content"]
    raw_content = chatgpt_response["choices"][0]["message"]["content"].gsub("\\'", "AAA").gsub('"', '\\"').gsub("'", '"').gsub("AAA", "'")
    @content = JSON.parse(raw_content)

    @quiz.update(title: @content[0]["topic"], user: current_user, content: @content)
    # @quiz.save!

    @content.each do |question|
      # how to get the quiz_id and question_id? params?
      @question = Question.create(quiz_id: @quiz.id, question: question["question"])
      @question.save!
      @choice1 = Choice.create(question_id: @question.id, choice: question["options"]["option1"]["body"], correct: question["options"]["option1"]["isItCorrect"])
      @choice1.save!
      @choice2 = Choice.create(question_id: @question.id, choice: question["options"]["option2"]["body"], correct: question["options"]["option2"]["isItCorrect"])
      @choice2.save!
      @choice3 = Choice.create(question_id: @question.id, choice: question["options"]["option3"]["body"], correct: question["options"]["option3"]["isItCorrect"])
      @choice3.save!
      @choice4 = Choice.create(question_id: @question.id, choice: question["options"]["option4"]["body"], correct: question["options"]["option4"]["isItCorrect"])
      @choice4.save!
    end
  end
end
