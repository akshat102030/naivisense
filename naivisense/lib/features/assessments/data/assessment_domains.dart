import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

enum DomainType { standard, behavioral, sensory }

class AssessmentItem {
  final String key;
  final String label;
  const AssessmentItem({required this.key, required this.label});
}

class AssessmentDomain {
  final String key;
  final String title;
  final IconData icon;
  final Color color;
  final DomainType type;
  final List<AssessmentItem> items;
  const AssessmentDomain({
    required this.key,
    required this.title,
    required this.icon,
    required this.color,
    this.type = DomainType.standard,
    required this.items,
  });
}

const kScoreLabels = ['Not Present', 'Emerging', 'Partial', 'Independent'];
const kScoreColors = [
  AppColors.softCoral,
  Color(0xFFFF8C00),
  AppColors.warmYellow,
  AppColors.mintGreen,
];

const kBehaviorFrequencies = ['daily', 'weekly', 'monthly'];

const kSensoryPatterns = ['seeking', 'avoiding', 'typical'];
const kSensoryPatternLabels = ['Seeking', 'Avoiding', 'Typical'];

const List<AssessmentDomain> kAssessmentDomains = [
  // 1. Attention & Executive Function
  AssessmentDomain(
    key:   'attention',
    title: 'Attention & Executive Function',
    icon:  Icons.psychology_outlined,
    color: Color(0xFF4A90E2),
    items: [
      AssessmentItem(key: 'eye_contact',             label: 'Eye Contact'),
      AssessmentItem(key: 'joint_attention',          label: 'Joint Attention'),
      AssessmentItem(key: 'response_to_name',         label: 'Response to Name'),
      AssessmentItem(key: 'sitting_tolerance',        label: 'Sitting Tolerance'),
      AssessmentItem(key: 'task_completion',          label: 'Task Completion'),
      AssessmentItem(key: 'attention_span',           label: 'Attention Span'),
      AssessmentItem(key: 'waiting_turn',             label: 'Waiting Turn'),
      AssessmentItem(key: 'impulse_control',          label: 'Impulse Control'),
      AssessmentItem(key: 'following_instructions',   label: 'Following Instructions'),
      AssessmentItem(key: 'transition_management',    label: 'Transition Management'),
      AssessmentItem(key: 'listening_skills',         label: 'Listening Skills'),
      AssessmentItem(key: 'hyperactivity_regulation', label: 'Hyperactivity Regulation'),
      AssessmentItem(key: 'distractibility',          label: 'Distractibility'),
      AssessmentItem(key: 'self_regulation',          label: 'Self Regulation'),
      AssessmentItem(key: 'working_memory',           label: 'Working Memory'),
      AssessmentItem(key: 'planning_skills',          label: 'Planning Skills'),
      AssessmentItem(key: 'cognitive_flexibility',    label: 'Cognitive Flexibility'),
    ],
  ),

  // 2. Behavioral Assessment (special domain)
  AssessmentDomain(
    key:   'behavioral',
    title: 'Behavioral Assessment',
    icon:  Icons.warning_amber_outlined,
    color: Color(0xFFFF7B7B),
    type:  DomainType.behavioral,
    items: [
      AssessmentItem(key: 'tantrums',               label: 'Tantrums'),
      AssessmentItem(key: 'aggression',             label: 'Aggression'),
      AssessmentItem(key: 'self_harm',              label: 'Self Harm'),
      AssessmentItem(key: 'property_destruction',   label: 'Property Destruction'),
      AssessmentItem(key: 'biting',                 label: 'Biting'),
      AssessmentItem(key: 'hitting',                label: 'Hitting'),
      AssessmentItem(key: 'throwing_objects',       label: 'Throwing Objects'),
      AssessmentItem(key: 'running_away',           label: 'Running Away / Elopement'),
      AssessmentItem(key: 'obsessions',             label: 'Obsessions / Rituals'),
      AssessmentItem(key: 'rigidity',               label: 'Rigidity / Inflexibility'),
      AssessmentItem(key: 'non_compliance',         label: 'Non-Compliance'),
      AssessmentItem(key: 'emotional_dysregulation',label: 'Emotional Dysregulation'),
      AssessmentItem(key: 'sleep_issues',           label: 'Sleep Issues'),
      AssessmentItem(key: 'food_selectivity',       label: 'Food Selectivity'),
      AssessmentItem(key: 'potty_issues',           label: 'Potty Issues'),
      AssessmentItem(key: 'meltdowns',              label: 'Meltdowns'),
    ],
  ),

  // 3. Social Communication
  AssessmentDomain(
    key:   'social_communication',
    title: 'Social Communication',
    icon:  Icons.people_outline,
    color: Color(0xFF9B59B6),
    items: [
      AssessmentItem(key: 'responds_to_name',       label: 'Responds to Name'),
      AssessmentItem(key: 'greeting',               label: 'Greeting'),
      AssessmentItem(key: 'eye_contact_interaction',label: 'Eye Contact During Interaction'),
      AssessmentItem(key: 'sharing',                label: 'Sharing'),
      AssessmentItem(key: 'turn_taking',            label: 'Turn Taking'),
      AssessmentItem(key: 'parallel_play',          label: 'Parallel Play'),
      AssessmentItem(key: 'interactive_play',       label: 'Interactive Play'),
      AssessmentItem(key: 'pretend_play',           label: 'Pretend Play'),
      AssessmentItem(key: 'conversation',           label: 'Conversation'),
      AssessmentItem(key: 'emotional_recognition',  label: 'Emotional Recognition'),
      AssessmentItem(key: 'peer_interaction',       label: 'Peer Interaction'),
      AssessmentItem(key: 'initiates_interaction',  label: 'Initiates Interaction'),
      AssessmentItem(key: 'maintains_interaction',  label: 'Maintains Interaction'),
      AssessmentItem(key: 'friendship_skills',      label: 'Friendship Skills'),
      AssessmentItem(key: 'social_awareness',       label: 'Social Awareness'),
      AssessmentItem(key: 'theory_of_mind',         label: 'Theory of Mind Indicators'),
    ],
  ),

  // 4. Receptive Language
  AssessmentDomain(
    key:   'receptive_language',
    title: 'Receptive Language',
    icon:  Icons.hearing_outlined,
    color: Color(0xFF1ABC9C),
    items: [
      AssessmentItem(key: 'understands_name',      label: 'Understands Own Name'),
      AssessmentItem(key: 'one_step_commands',     label: 'One-Step Commands'),
      AssessmentItem(key: 'two_step_commands',     label: 'Two-Step Commands'),
      AssessmentItem(key: 'wh_questions',          label: 'WH Questions'),
      AssessmentItem(key: 'object_identification', label: 'Object Identification'),
      AssessmentItem(key: 'action_identification', label: 'Action Identification'),
      AssessmentItem(key: 'body_parts',            label: 'Body Parts'),
      AssessmentItem(key: 'colors',                label: 'Colors'),
      AssessmentItem(key: 'shapes',                label: 'Shapes'),
      AssessmentItem(key: 'categories',            label: 'Categories'),
      AssessmentItem(key: 'prepositions',          label: 'Prepositions'),
      AssessmentItem(key: 'concepts',              label: 'Concepts (big/small, etc.)'),
      AssessmentItem(key: 'story_comprehension',   label: 'Story Comprehension'),
    ],
  ),

  // 5. Expressive Language
  AssessmentDomain(
    key:   'expressive_language',
    title: 'Expressive Language',
    icon:  Icons.record_voice_over_outlined,
    color: Color(0xFF2980B9),
    items: [
      AssessmentItem(key: 'babbling',          label: 'Babbling / Pre-verbal'),
      AssessmentItem(key: 'single_words',      label: 'Single Words'),
      AssessmentItem(key: 'two_word_phrases',  label: 'Two-Word Phrases'),
      AssessmentItem(key: 'three_word_phrases',label: 'Three-Word Phrases'),
      AssessmentItem(key: 'sentence_formation',label: 'Sentence Formation'),
      AssessmentItem(key: 'requesting',        label: 'Requesting'),
      AssessmentItem(key: 'commenting',        label: 'Commenting'),
      AssessmentItem(key: 'question_asking',   label: 'Question Asking'),
      AssessmentItem(key: 'conversation',      label: 'Conversation'),
      AssessmentItem(key: 'narration',         label: 'Narration'),
      AssessmentItem(key: 'grammar',           label: 'Grammar'),
      AssessmentItem(key: 'pronouns',          label: 'Pronouns'),
      AssessmentItem(key: 'vocabulary',        label: 'Vocabulary'),
    ],
  ),

  // 6. Speech Production
  AssessmentDomain(
    key:   'speech_production',
    title: 'Speech Production',
    icon:  Icons.mic_outlined,
    color: Color(0xFF16A085),
    items: [
      AssessmentItem(key: 'oral_motor',            label: 'Oral Motor Skills'),
      AssessmentItem(key: 'sound_production',      label: 'Sound Production'),
      AssessmentItem(key: 'articulation',          label: 'Articulation'),
      AssessmentItem(key: 'sound_joining',         label: 'Sound Joining'),
      AssessmentItem(key: 'word_production',       label: 'Word Production'),
      AssessmentItem(key: 'sentence_clarity',      label: 'Sentence Clarity'),
      AssessmentItem(key: 'speech_intelligibility',label: 'Speech Intelligibility'),
      AssessmentItem(key: 'voice_quality',         label: 'Voice Quality'),
      AssessmentItem(key: 'fluency',               label: 'Fluency'),
    ],
  ),

  // 7. Imitation Skills
  AssessmentDomain(
    key:   'imitation',
    title: 'Imitation Skills',
    icon:  Icons.content_copy_outlined,
    color: Color(0xFF8E44AD),
    items: [
      AssessmentItem(key: 'gross_motor_imitation', label: 'Gross Motor Imitation'),
      AssessmentItem(key: 'fine_motor_imitation',  label: 'Fine Motor Imitation'),
      AssessmentItem(key: 'oral_imitation',        label: 'Oral Imitation'),
      AssessmentItem(key: 'action_imitation',      label: 'Action Imitation'),
      AssessmentItem(key: 'object_imitation',      label: 'Object Imitation'),
      AssessmentItem(key: 'facial_imitation',      label: 'Facial Imitation'),
    ],
  ),

  // 8. Visual Perception
  AssessmentDomain(
    key:   'visual_perception',
    title: 'Visual Perception',
    icon:  Icons.visibility_outlined,
    color: Color(0xFF2C3E50),
    items: [
      AssessmentItem(key: 'matching_objects',      label: 'Matching Objects'),
      AssessmentItem(key: 'matching_pictures',     label: 'Matching Pictures'),
      AssessmentItem(key: 'visual_discrimination', label: 'Visual Discrimination'),
      AssessmentItem(key: 'pattern_recognition',   label: 'Pattern Recognition'),
      AssessmentItem(key: 'figure_ground',         label: 'Figure-Ground'),
      AssessmentItem(key: 'visual_closure',        label: 'Visual Closure'),
      AssessmentItem(key: 'visual_memory',         label: 'Visual Memory'),
      AssessmentItem(key: 'puzzle_skills',         label: 'Puzzle Skills'),
      AssessmentItem(key: 'sequencing',            label: 'Sequencing'),
    ],
  ),

  // 9. Fine Motor
  AssessmentDomain(
    key:   'fine_motor',
    title: 'Fine Motor Skills',
    icon:  Icons.front_hand_outlined,
    color: Color(0xFFE67E22),
    items: [
      AssessmentItem(key: 'pincer_grasp',           label: 'Pincer Grasp'),
      AssessmentItem(key: 'tripod_grasp',           label: 'Tripod Grasp'),
      AssessmentItem(key: 'peg_board',              label: 'Peg Board'),
      AssessmentItem(key: 'bead_stringing',         label: 'Bead Stringing'),
      AssessmentItem(key: 'cutting',                label: 'Cutting'),
      AssessmentItem(key: 'coloring',               label: 'Coloring'),
      AssessmentItem(key: 'tracing',                label: 'Tracing'),
      AssessmentItem(key: 'hand_strength',          label: 'Hand Strength'),
      AssessmentItem(key: 'bilateral_coordination', label: 'Bilateral Coordination'),
      AssessmentItem(key: 'hand_eye_coordination',  label: 'Hand-Eye Coordination'),
    ],
  ),

  // 10. Gross Motor
  AssessmentDomain(
    key:   'gross_motor',
    title: 'Gross Motor Skills',
    icon:  Icons.directions_run_outlined,
    color: Color(0xFF27AE60),
    items: [
      AssessmentItem(key: 'balance',        label: 'Balance'),
      AssessmentItem(key: 'jumping',        label: 'Jumping'),
      AssessmentItem(key: 'hopping',        label: 'Hopping'),
      AssessmentItem(key: 'running',        label: 'Running'),
      AssessmentItem(key: 'stair_climbing', label: 'Stair Climbing'),
      AssessmentItem(key: 'throwing',       label: 'Throwing'),
      AssessmentItem(key: 'catching',       label: 'Catching'),
      AssessmentItem(key: 'core_strength',  label: 'Core Strength'),
      AssessmentItem(key: 'motor_planning', label: 'Motor Planning'),
    ],
  ),

  // 11. Sensory Processing (special domain)
  AssessmentDomain(
    key:   'sensory',
    title: 'Sensory Processing',
    icon:  Icons.sensors_outlined,
    color: Color(0xFF6C3483),
    type:  DomainType.sensory,
    items: [
      AssessmentItem(key: 'visual',         label: 'Visual Sensory'),
      AssessmentItem(key: 'auditory',       label: 'Auditory Sensory'),
      AssessmentItem(key: 'tactile',        label: 'Tactile Sensory'),
      AssessmentItem(key: 'vestibular',     label: 'Vestibular Sensory'),
      AssessmentItem(key: 'proprioceptive', label: 'Proprioceptive Sensory'),
      AssessmentItem(key: 'oral_sensory',   label: 'Oral Sensory'),
    ],
  ),

  // 12. ADL
  AssessmentDomain(
    key:   'adl',
    title: 'Activities of Daily Living',
    icon:  Icons.home_outlined,
    color: Color(0xFF2ECC71),
    items: [
      AssessmentItem(key: 'eating',                label: 'Eating'),
      AssessmentItem(key: 'drinking',              label: 'Drinking'),
      AssessmentItem(key: 'dressing',              label: 'Dressing'),
      AssessmentItem(key: 'toileting',             label: 'Toileting'),
      AssessmentItem(key: 'bathing',               label: 'Bathing'),
      AssessmentItem(key: 'brushing',              label: 'Brushing Teeth'),
      AssessmentItem(key: 'hand_washing',          label: 'Hand Washing'),
      AssessmentItem(key: 'school_independence',   label: 'School Independence'),
      AssessmentItem(key: 'safety_awareness',      label: 'Safety Awareness'),
      AssessmentItem(key: 'community_participation',label: 'Community Participation'),
    ],
  ),

  // 13. Academics
  AssessmentDomain(
    key:   'academics',
    title: 'Academic Skills',
    icon:  Icons.school_outlined,
    color: Color(0xFFF39C12),
    items: [
      // Pre-Reading
      AssessmentItem(key: 'letter_recognition', label: 'Letter Recognition'),
      AssessmentItem(key: 'phonics',            label: 'Phonics'),
      AssessmentItem(key: 'sight_words',        label: 'Sight Words'),
      AssessmentItem(key: 'story_listening',    label: 'Story Listening'),
      AssessmentItem(key: 'reading_readiness',  label: 'Reading Readiness'),
      // Pre-Writing
      AssessmentItem(key: 'scribbling',         label: 'Scribbling'),
      AssessmentItem(key: 'tracing_writing',    label: 'Tracing (Writing)'),
      AssessmentItem(key: 'shapes_writing',     label: 'Shapes'),
      AssessmentItem(key: 'name_writing',       label: 'Name Writing'),
      AssessmentItem(key: 'sentence_writing',   label: 'Sentence Writing'),
      // Pre-Math
      AssessmentItem(key: 'counting',           label: 'Counting'),
      AssessmentItem(key: 'number_recognition', label: 'Number Recognition'),
      AssessmentItem(key: 'sorting',            label: 'Sorting'),
      AssessmentItem(key: 'sequencing_math',    label: 'Sequencing'),
      AssessmentItem(key: 'patterns',           label: 'Patterns'),
      AssessmentItem(key: 'addition',           label: 'Addition'),
      AssessmentItem(key: 'subtraction',        label: 'Subtraction'),
    ],
  ),

  // 14. Cognitive Skills
  AssessmentDomain(
    key:   'cognitive',
    title: 'Cognitive Skills',
    icon:  Icons.lightbulb_outline,
    color: Color(0xFF3498DB),
    items: [
      AssessmentItem(key: 'problem_solving',   label: 'Problem Solving'),
      AssessmentItem(key: 'cause_effect',      label: 'Cause & Effect'),
      AssessmentItem(key: 'classification',    label: 'Classification'),
      AssessmentItem(key: 'memory',            label: 'Memory'),
      AssessmentItem(key: 'reasoning',         label: 'Reasoning'),
      AssessmentItem(key: 'concept_formation', label: 'Concept Formation'),
      AssessmentItem(key: 'decision_making',   label: 'Decision Making'),
      AssessmentItem(key: 'generalization',    label: 'Generalization'),
    ],
  ),

  // 15. Emotional Regulation
  AssessmentDomain(
    key:   'emotional_regulation',
    title: 'Emotional Regulation',
    icon:  Icons.favorite_outline,
    color: Color(0xFFE91E63),
    items: [
      AssessmentItem(key: 'identifies_emotions', label: 'Identifies Emotions'),
      AssessmentItem(key: 'expresses_emotions',  label: 'Expresses Emotions'),
      AssessmentItem(key: 'calms_self',          label: 'Calms Self'),
      AssessmentItem(key: 'handles_frustration', label: 'Handles Frustration'),
      AssessmentItem(key: 'handles_changes',     label: 'Handles Changes'),
      AssessmentItem(key: 'anxiety_indicators',  label: 'Anxiety Indicators'),
      AssessmentItem(key: 'confidence_level',    label: 'Confidence Level'),
    ],
  ),
];
