import '../../../model/exam_record.dart';
import '../../../model/subject.dart';
import '../../../repository/exam/exam_repository.dart';

const exampleUserId = 'exampleUserId';
final now = DateTime.now();
final exampleRecords = <ExamRecord>[
  ExamRecord(
    id: 'exampleRecord1',
    exam: defaultExams[0],
    examDurationMinutes: Subject.language.defaultExamDuration,
    examStartedTime: now.subtract(const Duration(days: 21)),
    score: 70,
    userId: exampleUserId,
    title: '',
    feedback: '',
    wrongProblems: [],
    reviewProblems: [],
    createdAt: now,
  ),
  ExamRecord(
    id: 'exampleRecord2',
    exam: defaultExams[0],
    examDurationMinutes: Subject.language.defaultExamDuration,
    examStartedTime: now.subtract(const Duration(days: 14)),
    score: 82,
    userId: exampleUserId,
    title: '',
    feedback: '',
    wrongProblems: [],
    reviewProblems: [],
    createdAt: now,
  ),
  ExamRecord(
    id: 'exampleRecord3',
    exam: defaultExams[0],
    examDurationMinutes: Subject.language.defaultExamDuration,
    examStartedTime: now.subtract(const Duration(days: 7)),
    score: 78,
    userId: exampleUserId,
    title: '',
    feedback: '',
    wrongProblems: [],
    reviewProblems: [],
    createdAt: now,
  ),
  ExamRecord(
    id: 'exampleRecord4',
    exam: defaultExams[0],
    examDurationMinutes: Subject.language.defaultExamDuration,
    examStartedTime: now.subtract(const Duration(days: 0)),
    score: 85,
    userId: exampleUserId,
    title: '',
    feedback: '',
    wrongProblems: [],
    reviewProblems: [],
    createdAt: now,
  ),
  ExamRecord(
    id: 'exampleRecord5',
    exam: defaultExams[0],
    examDurationMinutes: Subject.language.defaultExamDuration,
    examStartedTime: now.subtract(const Duration(days: -7)),
    score: 89,
    userId: exampleUserId,
    title: '',
    feedback: '',
    wrongProblems: [],
    reviewProblems: [],
    createdAt: now,
  ),
  ExamRecord(
    id: 'exampleRecord6',
    exam: defaultExams[0],
    examDurationMinutes: Subject.language.defaultExamDuration,
    examStartedTime: now.subtract(const Duration(days: -14)),
    score: 82,
    userId: exampleUserId,
    title: '',
    feedback: '',
    wrongProblems: [],
    reviewProblems: [],
    createdAt: now,
  ),
  ExamRecord(
    id: 'exampleRecord7',
    exam: defaultExams[0],
    examDurationMinutes: Subject.language.defaultExamDuration,
    examStartedTime: now.subtract(const Duration(days: -21)),
    score: 95,
    userId: exampleUserId,
    title: '',
    feedback: '',
    wrongProblems: [],
    reviewProblems: [],
    createdAt: now,
  ),
  ExamRecord(
    id: 'exampleRecord8',
    exam: defaultExams[1],
    examDurationMinutes: Subject.math.defaultExamDuration,
    examStartedTime: now.subtract(const Duration(days: 21)),
    score: 80,
    userId: exampleUserId,
    title: '',
    feedback: '',
    wrongProblems: [],
    reviewProblems: [],
    createdAt: now,
  ),
  ExamRecord(
    id: 'exampleRecord9',
    exam: defaultExams[1],
    examDurationMinutes: Subject.math.defaultExamDuration,
    examStartedTime: now.subtract(const Duration(days: 17)),
    score: 80,
    userId: exampleUserId,
    title: '',
    feedback: '',
    wrongProblems: [],
    reviewProblems: [],
    createdAt: now,
  ),
  ExamRecord(
    id: 'exampleRecord10',
    exam: defaultExams[1],
    examDurationMinutes: Subject.math.defaultExamDuration,
    examStartedTime: now.subtract(const Duration(days: 14)),
    score: 88,
    userId: exampleUserId,
    title: '',
    feedback: '',
    wrongProblems: [],
    reviewProblems: [],
    createdAt: now,
  ),
  ExamRecord(
    id: 'exampleRecord11',
    exam: defaultExams[1],
    examDurationMinutes: Subject.math.defaultExamDuration,
    examStartedTime: now.subtract(const Duration(days: 10)),
    score: 84,
    userId: exampleUserId,
    title: '',
    feedback: '',
    wrongProblems: [],
    reviewProblems: [],
    createdAt: now,
  ),
  ExamRecord(
    id: 'exampleRecord12',
    exam: defaultExams[1],
    examDurationMinutes: Subject.math.defaultExamDuration,
    examStartedTime: now.subtract(const Duration(days: 7)),
    score: 80,
    userId: exampleUserId,
    title: '',
    feedback: '',
    wrongProblems: [],
    reviewProblems: [],
    createdAt: now,
  ),
  ExamRecord(
    id: 'exampleRecord13',
    exam: defaultExams[1],
    examDurationMinutes: Subject.math.defaultExamDuration,
    examStartedTime: now.subtract(const Duration(days: 3)),
    score: 84,
    userId: exampleUserId,
    title: '',
    feedback: '',
    wrongProblems: [],
    reviewProblems: [],
    createdAt: now,
  ),
  ExamRecord(
    id: 'exampleRecord14',
    exam: defaultExams[1],
    examDurationMinutes: Subject.math.defaultExamDuration,
    examStartedTime: now.subtract(const Duration(days: 0)),
    score: 92,
    userId: exampleUserId,
    title: '',
    feedback: '',
    wrongProblems: [],
    reviewProblems: [],
    createdAt: now,
  ),
  ExamRecord(
    id: 'exampleRecord15',
    exam: defaultExams[1],
    examDurationMinutes: Subject.math.defaultExamDuration,
    examStartedTime: now.subtract(const Duration(days: -4)),
    score: 88,
    userId: exampleUserId,
    title: '',
    feedback: '',
    wrongProblems: [],
    reviewProblems: [],
    createdAt: now,
  ),
  ExamRecord(
    id: 'exampleRecord16',
    exam: defaultExams[1],
    examDurationMinutes: Subject.math.defaultExamDuration,
    examStartedTime: now.subtract(const Duration(days: -7)),
    score: 84,
    userId: exampleUserId,
    title: '',
    feedback: '',
    wrongProblems: [],
    reviewProblems: [],
    createdAt: now,
  ),
  ExamRecord(
    id: 'exampleRecord17',
    exam: defaultExams[1],
    examDurationMinutes: Subject.math.defaultExamDuration,
    examStartedTime: now.subtract(const Duration(days: -11)),
    score: 86,
    userId: exampleUserId,
    title: '',
    feedback: '',
    wrongProblems: [],
    reviewProblems: [],
    createdAt: now,
  ),
  ExamRecord(
    id: 'exampleRecord18',
    exam: defaultExams[1],
    examDurationMinutes: Subject.math.defaultExamDuration,
    examStartedTime: now.subtract(const Duration(days: -14)),
    score: 89,
    userId: exampleUserId,
    title: '',
    feedback: '',
    wrongProblems: [],
    reviewProblems: [],
    createdAt: now,
  ),
  ExamRecord(
    id: 'exampleRecord19',
    exam: defaultExams[1],
    examDurationMinutes: Subject.math.defaultExamDuration,
    examStartedTime: now.subtract(const Duration(days: -18)),
    score: 92,
    userId: exampleUserId,
    title: '',
    feedback: '',
    wrongProblems: [],
    reviewProblems: [],
    createdAt: now,
  ),
  ExamRecord(
    id: 'exampleRecord20',
    exam: defaultExams[1],
    examDurationMinutes: Subject.math.defaultExamDuration,
    examStartedTime: now.subtract(const Duration(days: -21)),
    score: 84,
    userId: exampleUserId,
    title: '',
    feedback: '',
    wrongProblems: [],
    reviewProblems: [],
    createdAt: now,
  ),
  ExamRecord(
    id: 'exampleRecord21',
    exam: defaultExams[4],
    examDurationMinutes: Subject.investigation.defaultExamDuration,
    examStartedTime: now.subtract(const Duration(days: 21)),
    score: 42,
    userId: exampleUserId,
    title: '',
    feedback: '',
    wrongProblems: [],
    reviewProblems: [],
    createdAt: now,
  ),
  ExamRecord(
    id: 'exampleRecord22',
    exam: defaultExams[4],
    examDurationMinutes: Subject.investigation.defaultExamDuration,
    examStartedTime: now.subtract(const Duration(days: 10)),
    score: 39,
    userId: exampleUserId,
    title: '',
    feedback: '',
    wrongProblems: [],
    reviewProblems: [],
    createdAt: now,
  ),
  ExamRecord(
    id: 'exampleRecord23',
    exam: defaultExams[4],
    examDurationMinutes: Subject.investigation.defaultExamDuration,
    examStartedTime: now.subtract(const Duration(days: -10)),
    score: 47,
    userId: exampleUserId,
    title: '',
    feedback: '',
    wrongProblems: [],
    reviewProblems: [],
    createdAt: now,
  ),
  ExamRecord(
    id: 'exampleRecord24',
    exam: defaultExams[4],
    examDurationMinutes: Subject.investigation.defaultExamDuration,
    examStartedTime: now.subtract(const Duration(days: -21)),
    score: 45,
    userId: exampleUserId,
    title: '',
    feedback: '',
    wrongProblems: [],
    reviewProblems: [],
    createdAt: now,
  ),
];
