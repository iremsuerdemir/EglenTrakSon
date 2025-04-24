import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:gorsel_programlama_proje/models/user.dart';
import 'package:lottie/lottie.dart';
import 'package:gorsel_programlama_proje/models/question_list.dart';
import 'package:gorsel_programlama_proje/models/score_list.dart';
import 'package:gorsel_programlama_proje/pages/quiz_game_over.dart';
import 'package:gorsel_programlama_proje/pages/quizhomepage.dart';
import 'package:gorsel_programlama_proje/pages/score_screen.dart';
import 'package:gorsel_programlama_proje/pages/time_finish_page.dart';

class QuizPage extends StatefulWidget {
  final String category;
  const QuizPage({Key? key, required this.category}) : super(key: key);

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> with TickerProviderStateMixin {
  late final AudioPlayer player;
  late final AnimationController pageTransition;
  late final AnimationController lottieController;
  Timer? timer;

  int currentQuestionIndex = 0;
  int selectedAnswer = -1;
  int score = 0;
  int timeLeft = 40;

  bool isTimeUp = false;
  bool questionAnswered = false;
  bool showLottie = false;
  String lottieFile = '';

  // Jokers
  bool usedFiftyFifty = false;
  bool usedDoubleAnswer = false;
  bool usedSkipQuestion = false;
  bool doubleAnswerActive = false;
  int firstSelectedAnswer = -1;
  List<int> hiddenOptions = [];

  late List<Question> _questions;

  @override
  void initState() {
    super.initState();
    player = AudioPlayer();
    pageTransition = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    lottieController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _questions = QuestionList.getByCategory(widget.category);
    startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    pageTransition.dispose();
    lottieController.dispose();
    player.dispose();
    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (timeLeft > 0) {
        setState(() => timeLeft--);
        if (timeLeft == 10) {
          await player.play(AssetSource("sounds/alert.mp3"));
        }
      } else {
        t.cancel();
        // Süre dolunca skoru kaydet
        ScoreList.ekle(ScoreList(score: score, kullanici: currentUser));
        // ScoreScreen'e yönlendir
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ScoreScreen(score: score)),
        );
      }
    });
  }

  void checkAnswer(int index) async {
    if (questionAnswered) return;

    final question = _questions[currentQuestionIndex];
    final correctIndex = question.correctAnswerIndex;

    timer?.cancel();

    // Double Answer first attempt
    if (doubleAnswerActive && firstSelectedAnswer == -1) {
      firstSelectedAnswer = index;

      // Eğer ilk seçilen cevap doğruysa
      if (index == correctIndex) {
        setState(() {
          selectedAnswer = index;
          questionAnswered = true;
          showLottie = true;
          lottieFile = 'assets/animations/correct.json';
          score += 10;
        });

        await player.play(AssetSource("sounds/correct.mp3"));
        await lottieController.forward(from: 0.0);
        await Future.delayed(const Duration(seconds: 2));

        doubleAnswerActive = false; // Joker hakkı bitti
        goToNextQuestion();
      } else {
        // Yanlışsa beklet ve ikinci şansı tanı
        setState(() => selectedAnswer = index);
        await player.play(AssetSource("sounds/wrong.mp3"));
        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          selectedAnswer = -1;
          // ikinci deneme için bekliyor
        });
      }
      return;
    }

    // Double Answer second attempt
    if (doubleAnswerActive && firstSelectedAnswer != -1) {
      if (index == correctIndex) {
        setState(() {
          selectedAnswer = index;
          questionAnswered = true;
          showLottie = true;
          lottieFile = 'assets/animations/correct.json';
          score += 10;
        });

        await player.play(AssetSource("sounds/correct.mp3"));
        await lottieController.forward(from: 0.0);
        await Future.delayed(const Duration(seconds: 2));
        goToNextQuestion();
      } else {
        setState(() {
          selectedAnswer = index;
          questionAnswered = true;
          showLottie = true;
          lottieFile = 'assets/animations/wrong.json';
        });

        await player.play(AssetSource("sounds/wrong.mp3"));
        await lottieController.forward(from: 0.0);
        await Future.delayed(const Duration(seconds: 2));
        gameOver();
      }

      doubleAnswerActive = false; // Joker hakkı kullanıldı
      return;
    }

    // Normal değerlendirme (joker yoksa)
    setState(() {
      selectedAnswer = index;
      questionAnswered = true;
      showLottie = true;
      lottieFile =
          index == correctIndex
              ? 'assets/animations/correct.json'
              : 'assets/animations/wrong.json';
    });

    await player.play(
      AssetSource(
        index == correctIndex ? "sounds/correct.mp3" : "sounds/wrong.mp3",
      ),
    );
    await lottieController.forward(from: 0.0);
    await Future.delayed(const Duration(seconds: 2));

    if (index == correctIndex) {
      setState(() => score += 10);
      goToNextQuestion();
    } else {
      gameOver();
    }
  }

  void useFiftyFifty() {
    if (usedFiftyFifty || questionAnswered) return;
    final question = _questions[currentQuestionIndex];
    final correctIndex = question.correctAnswerIndex;
    List<int> options = List.generate(question.options.length, (i) => i)
      ..remove(correctIndex);
    options.shuffle();
    setState(() {
      usedFiftyFifty = true;
      hiddenOptions = [options[0], options[1]];
    });
  }

  void useDoubleAnswer() {
    if (usedDoubleAnswer || questionAnswered) return;
    setState(() {
      usedDoubleAnswer = true;
      doubleAnswerActive = true;
    });
  }

  void skipQuestion() {
    if (usedSkipQuestion || questionAnswered) return;
    setState(() => usedSkipQuestion = true);
    timer?.cancel();
    goToNextQuestion();
  }

  User currentUser = User(
    id: 2,
    email: 'user@example.com',
    username: 'user123',
  );

  void goToNextQuestion() async {
    setState(() {
      currentQuestionIndex++;
      selectedAnswer = -1;
      questionAnswered = false;
      showLottie = false;
      isTimeUp = false;
      doubleAnswerActive = false;
      hiddenOptions.clear();
      firstSelectedAnswer = -1;
      timeLeft = 40;
    });
    if (currentQuestionIndex < _questions.length) {
      await pageTransition.reverse();
      await pageTransition.forward();
      startTimer();
    } else {
      ScoreList.ekle(ScoreList(score: score, kullanici: currentUser));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ScoreScreen(score: score)),
      );
    }
  }

  void gameOver() {
    timer?.cancel();
    // Skoru kaydet
    ScoreList.ekle(ScoreList(score: score, kullanici: currentUser));
    // ScoreScreen'e yönlendir
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ScoreScreen(score: score)),
    );
  }

  Widget buildAnswer(int index) {
    final question = _questions[currentQuestionIndex];
    final correctIndex = question.correctAnswerIndex;
    if (usedFiftyFifty && hiddenOptions.contains(index))
      return const SizedBox.shrink();

    bool isCorrect = index == correctIndex;
    bool isSelected = index == selectedAnswer;
    bool isFirstWrong =
        doubleAnswerActive &&
        firstSelectedAnswer != -1 &&
        firstSelectedAnswer != correctIndex &&
        index == firstSelectedAnswer;

    Color bgColor = Colors.white;
    if (questionAnswered) {
      if (isCorrect)
        bgColor = Colors.green;
      else if (isSelected || isFirstWrong)
        bgColor = Colors.red;
    } else if (doubleAnswerActive && index == firstSelectedAnswer) {
      bgColor = Colors.orangeAccent;
    }

    return SizedBox(
      width: 200,
      child: GestureDetector(
        onTap: questionAnswered ? null : () => checkAnswer(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 5,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              question.options[index],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: bgColor == Colors.white ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildJokerButton(String asset, VoidCallback onTap, bool used) {
    return GestureDetector(
      onTap: used || questionAnswered ? null : onTap,
      child: Opacity(
        opacity: used ? 0.4 : 1.0,
        child: Container(
          width: 60,
          height: 60,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Image.asset(asset),
        ),
      ),
    );
  }

  Question get currentQuestion => _questions[currentQuestionIndex];
  @override
  Widget build(BuildContext context) {
    final question = _questions[currentQuestionIndex];
    return Scaffold(
      backgroundColor: Colors.deepPurple[700],
      body: Stack(
        children: [
          SafeArea(
            child: FadeTransition(
              opacity: pageTransition,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Card(
                            color: Colors.deepPurple[300],
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.emoji_events,
                                        color: Colors.amberAccent,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        "Skor: $score",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.timer,
                                        color: Colors.redAccent,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        "Süre: $timeLeft",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(_questions.length, (i) {
                              bool active = i == currentQuestionIndex;
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4.0,
                                ),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: active ? 30 : 20,
                                  height: active ? 30 : 20,
                                  decoration: BoxDecoration(
                                    color:
                                        active
                                            ? Colors.orangeAccent
                                            : Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${i + 1}',
                                    style: TextStyle(
                                      color:
                                          active
                                              ? Colors.white
                                              : Colors.deepPurple,
                                      fontSize: active ? 16 : 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 20),
                          Card(
                            color: Colors.deepPurple[300],
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(
                                question.questionText,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Column(
                            children: List.generate(
                              question.options.length,
                              (i) => buildAnswer(i),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              buildJokerButton(
                                'assets/icons/fifty.png',
                                useFiftyFifty,
                                usedFiftyFifty,
                              ),
                              buildJokerButton(
                                'assets/icons/double.png',
                                useDoubleAnswer,
                                usedDoubleAnswer,
                              ),
                              buildJokerButton(
                                'assets/icons/skip.png',
                                skipQuestion,
                                usedSkipQuestion,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (showLottie)
            Positioned.fill(
              child: Center(
                child: Opacity(
                  opacity: 0.8,
                  child: Lottie.asset(
                    lottieFile,
                    controller: lottieController,
                    onLoaded:
                        (comp) => lottieController.duration = comp.duration,
                  ),
                ),
              ),
            ),
          Positioned(
            top: 20,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed:
                  () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => QuizHomePage(category: widget.category),
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
