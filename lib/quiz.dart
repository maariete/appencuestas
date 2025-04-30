import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Quiz extends StatefulWidget {
  final List<Map<String, Object>> questions;
  final String quizTitle;
  final IconData quizIcon;
  
  const Quiz({
    super.key, 
    required this.questions,
    required this.quizTitle,
    required this.quizIcon, required bool showFinalForm,
  });

  @override
  State<Quiz> createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  List<String> userAnswers = [];
  int currentQuestionIndex = 0;
  var activePage = "start_screen";

  void play() {
    setState(() {
      activePage = "Questions";
    });
  }

  void onSelect(String answer) {
    userAnswers.add(answer);
    if (userAnswers.length < widget.questions.length) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      setState(() {
        activePage = 'result_screen';
      });
    }
  }

  void restartQuiz() {
    setState(() {
      userAnswers = [];
      currentQuestionIndex = 0;
      activePage = 'Questions';
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget screenWidget = StartScreen(
      play, 
      widget.quizTitle,
      widget.quizIcon,
    );

    if (activePage == 'Questions') {
      screenWidget = QuestionScreen(
        onSelect: onSelect,
        question: widget.questions[currentQuestionIndex],
        questionIndex: currentQuestionIndex,
        totalQuestions: widget.questions.length,
      );
    }
    
    if (activePage == 'result_screen') {
      screenWidget = ResultsScreen(
        chosenAnswers: userAnswers,
        onRestart: restartQuiz,
        questions: widget.questions,
        quizTitle: widget.quizTitle,
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          widget.quizTitle,
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: screenWidget,
    );
  }
}

class StartScreen extends StatelessWidget {
  final VoidCallback startQuiz;
  final String quizTitle;
  final IconData quizIcon;

  const StartScreen(
    this.startQuiz, 
    this.quizTitle,
    this.quizIcon, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF5F5F5),
            Color(0xFFE8F5E9),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF2E7D32).withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                quizIcon,
                size: 60,
                color: const Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Cuestionario de $quizTitle',
              style: GoogleFonts.playfairDisplay(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Responde las siguientes preguntas\ny pon a prueba tus conocimientos',
              style: GoogleFonts.raleway(
                fontSize: 16,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: startQuiz,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 3,
              ),
              child: Text(
                'Comenzar',
                style: GoogleFonts.raleway(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuestionScreen extends StatelessWidget {
  final Map<String, Object> question;
  final void Function(String answer) onSelect;
  final int questionIndex;
  final int totalQuestions;

  const QuestionScreen({
    super.key,
    required this.question,
    required this.onSelect,
    required this.questionIndex,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF5F5F5),
            Color(0xFFE8F5E9),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: (questionIndex + 1) / totalQuestions,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 20),
          Text(
            'Pregunta ${questionIndex + 1}/$totalQuestions',
            style: GoogleFonts.raleway(
              fontSize: 16,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            question['question'] as String,
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: ListView.separated(
              itemCount: (question['answers'] as List<String>).length,
              separatorBuilder: (context, index) => const SizedBox(height: 15),
              itemBuilder: (context, index) {
                final answer = (question['answers'] as List<String>)[index];
                return ElevatedButton(
                  onPressed: () => onSelect(answer),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF2E7D32),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(
                        color: Color(0xFF2E7D32),
                        width: 1.5,
                      ),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    answer,
                    style: GoogleFonts.raleway(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ResultsScreen extends StatelessWidget {
  final List<String> chosenAnswers;
  final VoidCallback onRestart;
  final List<Map<String, Object>> questions;
  final String quizTitle;

  const ResultsScreen({
    super.key,
    required this.chosenAnswers,
    required this.onRestart,
    required this.questions,
    required this.quizTitle,
  });

  @override
  Widget build(BuildContext context) {
    final numCorrect = chosenAnswers.where((answer) {
      return answer == questions[chosenAnswers.indexOf(answer)]['correctAnswer'];
    }).length;

    final percentage = (numCorrect / questions.length * 100).round();

    return Container(
      padding: const EdgeInsets.all(30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF5F5F5),
            Color(0xFFE8F5E9),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Resultado Win Encuestas',
              style: GoogleFonts.playfairDisplay(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2E7D32).withOpacity(0.1),
                border: Border.all(
                  color: const Color(0xFF2E7D32),
                  width: 3,
                ),
              ),
              child: Center(
                child: Text(
                  '$percentage%',
                  style: GoogleFonts.raleway(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Has acertado $numCorrect de ${questions.length} preguntas',
              style: GoogleFonts.raleway(
                fontSize: 18,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: onRestart,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'Reintentar',
                style: GoogleFonts.raleway(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}