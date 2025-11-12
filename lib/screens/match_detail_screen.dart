import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design_system/design_system.dart';
import '../design_system/components.dart';
import '../services/analytics_service.dart';

// Match Status Enum
enum MatchStatus { waiting, ongoing, completed, disputed }

// Match Models
class Match {
  final String id;
  final String title;
  final DateTime dateTime;
  final String court;
  final String club;
  final List<Player> team1;
  final List<Player> team2;
  final MatchStatus status;
  final Score? score;
  final List<ChatMessage> messages;
  final int? eloChange;
  final int? xpGained;
  final bool? isWinner;

  Match({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.court,
    required this.club,
    required this.team1,
    required this.team2,
    required this.status,
    this.score,
    this.messages = const [],
    this.eloChange,
    this.xpGained,
    this.isWinner,
  });
}

class Player {
  final String id;
  final String name;
  final String? avatarUrl;
  final int elo;
  final int level;

  Player({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.elo,
    required this.level,
  });
}

class Score {
  final int team1Set1;
  final int team2Set1;
  final int team1Set2;
  final int team2Set2;
  final int? team1Set3;
  final int? team2Set3;
  final bool isConfirmed;
  final String? confirmedBy;
  final bool needsOpponentConfirmation;

  Score({
    required this.team1Set1,
    required this.team2Set1,
    required this.team1Set2,
    required this.team2Set2,
    this.team1Set3,
    this.team2Set3,
    this.isConfirmed = false,
    this.confirmedBy,
    this.needsOpponentConfirmation = false,
  });

  String get displayScore {
    String result = '$team1Set1-$team2Set1, $team1Set2-$team2Set2';
    if (team1Set3 != null && team2Set3 != null) {
      result += ', $team1Set3-$team2Set3';
    }
    return result;
  }
}

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final bool isSystemMessage;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    this.isSystemMessage = false,
  });
}

class PadelMatchDetailScreen extends StatefulWidget {
  final Match match;

  const PadelMatchDetailScreen({
    super.key,
    required this.match,
  });

  @override
  State<PadelMatchDetailScreen> createState() => _PadelMatchDetailScreenState();
}

class _PadelMatchDetailScreenState extends State<PadelMatchDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  
  late Match _currentMatch;

  @override
  void initState() {
    super.initState();
    _currentMatch = widget.match;
    _setupAnimations();
    
    AnalyticsService.logEvent(
      name: 'match_detail_viewed',
      parameters: {
        'match_id': _currentMatch.id,
        'match_status': _currentMatch.status.name,
      },
    );
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _chatController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey.shade700,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
        title: Text(
          'Match Details',
          style: TextStyle(
            color: Colors.grey.shade800,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: Colors.grey.shade700),
            onPressed: _shareMatch,
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _slideAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 50 * (1 - _slideAnimation.value)),
            child: Opacity(
              opacity: _slideAnimation.value,
              child: _buildContent(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(PadelSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMatchHeader(),
          const SizedBox(height: PadelSpacing.lg),
          _buildTeamsDisplay(),
          const SizedBox(height: PadelSpacing.lg),
          _buildStatusCard(),
          const SizedBox(height: PadelSpacing.lg),
          if (_currentMatch.status != MatchStatus.waiting) _buildScoreSection(),
          const SizedBox(height: PadelSpacing.lg),
          _buildChatSection(),
          const SizedBox(height: PadelSpacing.lg),
          _buildActionButtons(),
          if (_currentMatch.status == MatchStatus.completed) ...[
            const SizedBox(height: PadelSpacing.lg),
            _buildPostMatchSummary(),
          ],
        ],
      ),
    );
  }

  Widget _buildMatchHeader() {
    return PadelCard(
      child: Padding(
        padding: const EdgeInsets.all(PadelSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.sports_tennis,
                  color: PadelColors.primary,
                  size: 24,
                ),
                const SizedBox(width: PadelSpacing.sm),
                Expanded(
                  child: Text(
                    _currentMatch.title,
                    style: PadelTypography.h6.copyWith(
                      fontWeight: FontWeight.bold,
                      color: PadelColors.primary,
                    ),
                  ),
                ),
                _buildStatusBadge(),
              ],
            ),
            const SizedBox(height: PadelSpacing.md),
            Row(
              children: [
                Icon(Icons.schedule, color: PadelColors.textSecondary, size: 20),
                const SizedBox(width: PadelSpacing.sm),
                Text(
                  '${_formatDate(_currentMatch.dateTime)} at ${_formatTime(_currentMatch.dateTime)}',
                  style: PadelTypography.bodyMedium.copyWith(
                    color: PadelColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: PadelSpacing.sm),
            Row(
              children: [
                Icon(Icons.location_on, color: PadelColors.textSecondary, size: 20),
                const SizedBox(width: PadelSpacing.sm),
                Expanded(
                  child: Text(
                    '${_currentMatch.court} - ${_currentMatch.club}',
                    style: PadelTypography.bodyMedium.copyWith(
                      color: PadelColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    PadelBadgeStyle style;
    String text;
    
    switch (_currentMatch.status) {
      case MatchStatus.waiting:
        style = PadelBadgeStyle.warning;
        text = 'Waiting';
        break;
      case MatchStatus.ongoing:
        style = PadelBadgeStyle.info;
        text = 'Ongoing';
        break;
      case MatchStatus.completed:
        style = PadelBadgeStyle.success;
        text = 'Completed';
        break;
      case MatchStatus.disputed:
        style = PadelBadgeStyle.error;
        text = 'Disputed';
        break;
    }

    return PadelBadge(text: text, style: style);
  }

  Widget _buildTeamsDisplay() {
    return PadelCard(
      child: Padding(
        padding: const EdgeInsets.all(PadelSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Teams',
              style: PadelTypography.h6.copyWith(
                fontWeight: FontWeight.bold,
                color: PadelColors.primary,
              ),
            ),
            const SizedBox(height: PadelSpacing.md),
            Row(
              children: [
                Expanded(child: _buildTeam('Team 1', _currentMatch.team1)),
                Container(
                  width: 2,
                  height: 80,
                  color: PadelColors.grey200,
                  margin: const EdgeInsets.symmetric(horizontal: PadelSpacing.md),
                ),
                Expanded(child: _buildTeam('Team 2', _currentMatch.team2)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeam(String teamName, List<Player> players) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          teamName,
          style: PadelTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: PadelColors.textSecondary,
          ),
        ),
        const SizedBox(height: PadelSpacing.sm),
        ...players.map((player) => _buildPlayerCard(player)),
      ],
    );
  }

  Widget _buildPlayerCard(Player player) {
    return Container(
      margin: const EdgeInsets.only(bottom: PadelSpacing.sm),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: PadelColors.primary.withOpacity(0.1),
            backgroundImage: player.avatarUrl != null 
              ? NetworkImage(player.avatarUrl!) 
              : null,
            child: player.avatarUrl == null
              ? Icon(Icons.person, color: PadelColors.primary, size: 20)
              : null,
          ),
          const SizedBox(width: PadelSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: PadelTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Elo: ${player.elo} • Level ${player.level}',
                  style: PadelTypography.caption.copyWith(
                    color: PadelColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    String statusText;
    String statusDescription;
    IconData statusIcon;
    Color statusColor;

    switch (_currentMatch.status) {
      case MatchStatus.waiting:
        statusText = 'Waiting for Match to Start';
        statusDescription = 'All players should arrive 10 minutes before the scheduled time.';
        statusIcon = Icons.schedule;
        statusColor = PadelColors.warning;
        break;
      case MatchStatus.ongoing:
        statusText = 'Match in Progress';
        statusDescription = 'Good luck! Remember to confirm the score after the match.';
        statusIcon = Icons.sports_tennis;
        statusColor = PadelColors.info;
        break;
      case MatchStatus.completed:
        statusText = 'Match Completed';
        statusDescription = 'Great game! Check your XP and Elo changes below.';
        statusIcon = Icons.emoji_events;
        statusColor = PadelColors.success;
        break;
      case MatchStatus.disputed:
        statusText = 'Score Under Review';
        statusDescription = 'There\'s a dispute about the score. Admin review in progress.';
        statusIcon = Icons.gavel;
        statusColor = PadelColors.error;
        break;
    }

    return PadelCard(
      child: Padding(
        padding: const EdgeInsets.all(PadelSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(PadelSpacing.sm),
              ),
              child: Icon(statusIcon, color: statusColor, size: 24),
            ),
            const SizedBox(width: PadelSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusText,
                    style: PadelTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: PadelSpacing.xs),
                  Text(
                    statusDescription,
                    style: PadelTypography.caption.copyWith(
                      color: PadelColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreSection() {
    return PadelCard(
      child: Padding(
        padding: const EdgeInsets.all(PadelSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Score',
                  style: PadelTypography.h6.copyWith(
                    fontWeight: FontWeight.bold,
                    color: PadelColors.primary,
                  ),
                ),
                if (_currentMatch.status == MatchStatus.ongoing)
                  PadelButton(
                    text: 'Enter Score',
                    onPressed: () => _showScoreInputDialog(),
                    style: PadelButtonStyle.outline,
                    size: PadelButtonSize.small,
                  ),
              ],
            ),
            const SizedBox(height: PadelSpacing.md),
            if (_currentMatch.score != null) ...[
              _buildScoreDisplay(_currentMatch.score!),
              if (_currentMatch.score!.needsOpponentConfirmation) ...[
                const SizedBox(height: PadelSpacing.md),
                Container(
                  padding: const EdgeInsets.all(PadelSpacing.md),
                  decoration: BoxDecoration(
                    color: PadelColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(PadelSpacing.sm),
                    border: Border.all(color: PadelColors.warning.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.schedule, color: PadelColors.warning, size: 20),
                      const SizedBox(width: PadelSpacing.sm),
                      Expanded(
                        child: Text(
                          'Waiting for opponent confirmation',
                          style: PadelTypography.bodyMedium.copyWith(
                            color: PadelColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ] else ...[
              Container(
                padding: const EdgeInsets.all(PadelSpacing.lg),
                decoration: BoxDecoration(
                  color: PadelColors.grey100,
                  borderRadius: BorderRadius.circular(PadelSpacing.sm),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sports_score, color: PadelColors.textSecondary, size: 24),
                    const SizedBox(width: PadelSpacing.sm),
                    Text(
                      'No score entered yet',
                      style: PadelTypography.bodyMedium.copyWith(
                        color: PadelColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScoreDisplay(Score score) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              'Team 1',
              style: PadelTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: PadelColors.textSecondary,
              ),
            ),
            Text(
              'Sets',
              style: PadelTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: PadelColors.textSecondary,
              ),
            ),
            Text(
              'Team 2',
              style: PadelTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: PadelColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: PadelSpacing.sm),
        _buildSetScore('Set 1', score.team1Set1, score.team2Set1),
        _buildSetScore('Set 2', score.team1Set2, score.team2Set2),
        if (score.team1Set3 != null && score.team2Set3 != null)
          _buildSetScore('Set 3', score.team1Set3!, score.team2Set3!),
        if (score.isConfirmed) ...[
          const SizedBox(height: PadelSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: PadelColors.success, size: 20),
              const SizedBox(width: PadelSpacing.sm),
              Text(
                'Score confirmed',
                style: PadelTypography.bodyMedium.copyWith(
                  color: PadelColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSetScore(String setName, int team1Score, int team2Score) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: PadelSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: team1Score > team2Score 
                ? PadelColors.success.withOpacity(0.1) 
                : PadelColors.grey100,
              borderRadius: BorderRadius.circular(PadelSpacing.sm),
              border: Border.all(
                color: team1Score > team2Score 
                  ? PadelColors.success 
                  : PadelColors.grey300,
              ),
            ),
            child: Center(
              child: Text(
                team1Score.toString(),
                style: PadelTypography.h6.copyWith(
                  fontWeight: FontWeight.bold,
                  color: team1Score > team2Score 
                    ? PadelColors.success 
                    : PadelColors.textPrimary,
                ),
              ),
            ),
          ),
          Text(
            setName,
            style: PadelTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: PadelColors.textSecondary,
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: team2Score > team1Score 
                ? PadelColors.success.withOpacity(0.1) 
                : PadelColors.grey100,
              borderRadius: BorderRadius.circular(PadelSpacing.sm),
              border: Border.all(
                color: team2Score > team1Score 
                  ? PadelColors.success 
                  : PadelColors.grey300,
              ),
            ),
            child: Center(
              child: Text(
                team2Score.toString(),
                style: PadelTypography.h6.copyWith(
                  fontWeight: FontWeight.bold,
                  color: team2Score > team1Score 
                    ? PadelColors.success 
                    : PadelColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatSection() {
    return PadelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(PadelSpacing.lg),
            child: Text(
              'Match Chat',
              style: PadelTypography.h6.copyWith(
                fontWeight: FontWeight.bold,
                color: PadelColors.primary,
              ),
            ),
          ),
          Container(
            height: 200,
            padding: const EdgeInsets.symmetric(horizontal: PadelSpacing.lg),
            child: _currentMatch.messages.isNotEmpty
              ? ListView.builder(
                  controller: _chatScrollController,
                  itemCount: _currentMatch.messages.length,
                  itemBuilder: (context, index) {
                    return _buildChatMessage(_currentMatch.messages[index]);
                  },
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        color: PadelColors.textSecondary,
                        size: 32,
                      ),
                      const SizedBox(height: PadelSpacing.sm),
                      Text(
                        'No messages yet',
                        style: PadelTypography.bodyMedium.copyWith(
                          color: PadelColors.textSecondary,
                        ),
                      ),
                      Text(
                        'Start the conversation!',
                        style: PadelTypography.caption.copyWith(
                          color: PadelColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
          ),
          Container(
            padding: const EdgeInsets.all(PadelSpacing.lg),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: PadelColors.grey200),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: PadelTextField(
                    placeholder: 'Type a message...',
                    value: _chatController.text,
                    onChanged: (value) => _chatController.text = value,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: PadelSpacing.sm),
                PadelButton(
                  text: 'Send',
                  onPressed: _sendMessage,
                  style: PadelButtonStyle.primary,
                  size: PadelButtonSize.small,
                  icon: Icons.send,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessage(ChatMessage message) {
    final bool isCurrentUser = message.senderId == 'current_user'; // Replace with actual user ID
    
    return Container(
      margin: const EdgeInsets.only(bottom: PadelSpacing.sm),
      child: Row(
        mainAxisAlignment: isCurrentUser 
          ? MainAxisAlignment.end 
          : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isCurrentUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: PadelColors.primary.withOpacity(0.1),
              child: Text(
                message.senderName[0].toUpperCase(),
                style: PadelTypography.caption.copyWith(
                  color: PadelColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: PadelSpacing.sm),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(PadelSpacing.md),
              decoration: BoxDecoration(
                color: isCurrentUser 
                  ? PadelColors.primary 
                  : PadelColors.grey100,
                borderRadius: BorderRadius.circular(PadelSpacing.md),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isCurrentUser)
                    Text(
                      message.senderName,
                      style: PadelTypography.caption.copyWith(
                        color: PadelColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  Text(
                    message.message,
                    style: PadelTypography.bodyMedium.copyWith(
                      color: isCurrentUser 
                        ? Colors.white 
                        : PadelColors.textPrimary,
                    ),
                  ),
                  Text(
                    _formatTime(message.timestamp),
                    style: PadelTypography.caption.copyWith(
                      color: isCurrentUser 
                        ? Colors.white.withOpacity(0.7) 
                        : PadelColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isCurrentUser) ...[
            const SizedBox(width: PadelSpacing.sm),
            CircleAvatar(
              radius: 16,
              backgroundColor: PadelColors.accent.withOpacity(0.1),
              child: Text(
                'You'[0].toUpperCase(),
                style: PadelTypography.caption.copyWith(
                  color: PadelColors.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (_currentMatch.status == MatchStatus.waiting) ...[
          SizedBox(
            width: double.infinity,
            child: PadelButton(
              text: 'Start Match',
              onPressed: _startMatch,
              style: PadelButtonStyle.primary,
              icon: Icons.play_arrow,
            ),
          ),
        ] else if (_currentMatch.status == MatchStatus.ongoing) ...[
          Row(
            children: [
              Expanded(
                child: PadelButton(
                  text: 'Confirm Score',
                  onPressed: () => _showScoreInputDialog(),
                  style: PadelButtonStyle.primary,
                  icon: Icons.sports_score,
                ),
              ),
              const SizedBox(width: PadelSpacing.md),
              Expanded(
                child: PadelButton(
                  text: 'End Match',
                  onPressed: _endMatch,
                  style: PadelButtonStyle.secondary,
                  icon: Icons.stop,
                ),
              ),
            ],
          ),
        ] else if (_currentMatch.status == MatchStatus.completed) ...[
          Row(
            children: [
              Expanded(
                child: PadelButton(
                  text: 'Rematch',
                  onPressed: _requestRematch,
                  style: PadelButtonStyle.outline,
                  icon: Icons.refresh,
                ),
              ),
              const SizedBox(width: PadelSpacing.md),
              Expanded(
                child: PadelButton(
                  text: 'Share Result',
                  onPressed: _shareMatch,
                  style: PadelButtonStyle.secondary,
                  icon: Icons.share,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildPostMatchSummary() {
    if (_currentMatch.status != MatchStatus.completed) return const SizedBox();

    return PadelCard(
      child: Padding(
        padding: const EdgeInsets.all(PadelSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.emoji_events,
                  color: PadelColors.accent,
                  size: 24,
                ),
                const SizedBox(width: PadelSpacing.sm),
                Text(
                  'Post-Match Summary',
                  style: PadelTypography.h6.copyWith(
                    fontWeight: FontWeight.bold,
                    color: PadelColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: PadelSpacing.md),
            
            // Win/Loss Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: PadelSpacing.lg,
                    vertical: PadelSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    gradient: _currentMatch.isWinner == true
                      ? LinearGradient(
                          colors: [PadelColors.success, PadelColors.success.withOpacity(0.7)],
                        )
                      : LinearGradient(
                          colors: [PadelColors.error, PadelColors.error.withOpacity(0.7)],
                        ),
                    borderRadius: BorderRadius.circular(PadelSpacing.lg),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _currentMatch.isWinner == true ? Icons.emoji_events : Icons.handshake,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(width: PadelSpacing.sm),
                      Text(
                        _currentMatch.isWinner == true ? 'VICTORY!' : 'GOOD GAME!',
                        style: PadelTypography.h5.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: PadelSpacing.lg),
            
            // XP and Elo Changes
            Row(
              children: [
                Expanded(
                  child: _buildStatChange(
                    'XP Gained',
                    '+${_currentMatch.xpGained ?? 50}',
                    Icons.star,
                    PadelColors.accent,
                  ),
                ),
                const SizedBox(width: PadelSpacing.md),
                Expanded(
                  child: _buildStatChange(
                    'Elo Change',
                    '${_currentMatch.eloChange != null ? (_currentMatch.eloChange! >= 0 ? '+' : '') : '+'}${_currentMatch.eloChange ?? 15}',
                    Icons.trending_up,
                    _currentMatch.eloChange != null && _currentMatch.eloChange! < 0 
                      ? PadelColors.error 
                      : PadelColors.success,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChange(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(PadelSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(PadelSpacing.sm),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: PadelSpacing.sm),
          Text(
            value,
            style: PadelTypography.h6.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: PadelTypography.caption.copyWith(
              color: PadelColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // Action Methods
  void _shareMatch() {
    AnalyticsService.logEvent(
      name: 'match_shared',
      parameters: {'match_id': _currentMatch.id},
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Match details shared!')),
    );
  }

  void _startMatch() {
    setState(() {
      _currentMatch = Match(
        id: _currentMatch.id,
        title: _currentMatch.title,
        dateTime: _currentMatch.dateTime,
        court: _currentMatch.court,
        club: _currentMatch.club,
        team1: _currentMatch.team1,
        team2: _currentMatch.team2,
        status: MatchStatus.ongoing,
        score: _currentMatch.score,
        messages: _currentMatch.messages,
      );
    });

    AnalyticsService.logEvent(
      name: 'match_started',
      parameters: {'match_id': _currentMatch.id},
    );

    HapticFeedback.lightImpact();
  }

  void _endMatch() {
    if (_currentMatch.score == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the score before ending the match')),
      );
      return;
    }

    setState(() {
      _currentMatch = Match(
        id: _currentMatch.id,
        title: _currentMatch.title,
        dateTime: _currentMatch.dateTime,
        court: _currentMatch.court,
        club: _currentMatch.club,
        team1: _currentMatch.team1,
        team2: _currentMatch.team2,
        status: MatchStatus.completed,
        score: _currentMatch.score,
        messages: _currentMatch.messages,
        eloChange: 15,
        xpGained: 50,
        isWinner: true, // This would be calculated based on score
      );
    });

    AnalyticsService.logEvent(
      name: 'match_completed',
      parameters: {
        'match_id': _currentMatch.id,
        'final_score': _currentMatch.score?.displayScore ?? '',
      },
    );

    HapticFeedback.mediumImpact();
  }

  void _requestRematch() {
    AnalyticsService.logEvent(
      name: 'rematch_requested',
      parameters: {'match_id': _currentMatch.id},
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rematch request sent to all players!')),
    );
  }

  void _sendMessage() {
    if (_chatController.text.trim().isEmpty) return;

    final newMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'current_user',
      senderName: 'You',
      message: _chatController.text.trim(),
      timestamp: DateTime.now(),
    );

    setState(() {
      _currentMatch = Match(
        id: _currentMatch.id,
        title: _currentMatch.title,
        dateTime: _currentMatch.dateTime,
        court: _currentMatch.court,
        club: _currentMatch.club,
        team1: _currentMatch.team1,
        team2: _currentMatch.team2,
        status: _currentMatch.status,
        score: _currentMatch.score,
        messages: [..._currentMatch.messages, newMessage],
        eloChange: _currentMatch.eloChange,
        xpGained: _currentMatch.xpGained,
        isWinner: _currentMatch.isWinner,
      );
    });

    _chatController.clear();
    
    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chatScrollController.animateTo(
        _chatScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    AnalyticsService.logEvent(
      name: 'match_message_sent',
      parameters: {'match_id': _currentMatch.id},
    );
  }

  void _showScoreInputDialog() {
    showDialog(
      context: context,
      builder: (context) => PadelScoreInputDialog(
        onScoreSubmitted: _handleScoreSubmission,
      ),
    );
  }

  void _handleScoreSubmission(Score score) {
    setState(() {
      _currentMatch = Match(
        id: _currentMatch.id,
        title: _currentMatch.title,
        dateTime: _currentMatch.dateTime,
        court: _currentMatch.court,
        club: _currentMatch.club,
        team1: _currentMatch.team1,
        team2: _currentMatch.team2,
        status: _currentMatch.status,
        score: score,
        messages: _currentMatch.messages,
        eloChange: _currentMatch.eloChange,
        xpGained: _currentMatch.xpGained,
        isWinner: _currentMatch.isWinner,
      );
    });

    AnalyticsService.logEvent(
      name: 'match_score_entered',
      parameters: {
        'match_id': _currentMatch.id,
        'score': score.displayScore,
      },
    );

    HapticFeedback.lightImpact();
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}

// Score Input Dialog
class PadelScoreInputDialog extends StatefulWidget {
  final Function(Score) onScoreSubmitted;

  const PadelScoreInputDialog({
    super.key,
    required this.onScoreSubmitted,
  });

  @override
  State<PadelScoreInputDialog> createState() => _PadelScoreInputDialogState();
}

class _PadelScoreInputDialogState extends State<PadelScoreInputDialog> {
  int team1Set1 = 0;
  int team2Set1 = 0;
  int team1Set2 = 0;
  int team2Set2 = 0;
  int? team1Set3;
  int? team2Set3;
  bool hasThirdSet = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(PadelSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(PadelSpacing.lg),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter Match Score',
              style: PadelTypography.h6.copyWith(
                fontWeight: FontWeight.bold,
                color: PadelColors.primary,
              ),
            ),
            const SizedBox(height: PadelSpacing.lg),
            
            // Set 1
            _buildSetInput('Set 1', team1Set1, team2Set1, (t1, t2) {
              setState(() {
                team1Set1 = t1;
                team2Set1 = t2;
              });
            }),
            
            const SizedBox(height: PadelSpacing.md),
            
            // Set 2
            _buildSetInput('Set 2', team1Set2, team2Set2, (t1, t2) {
              setState(() {
                team1Set2 = t1;
                team2Set2 = t2;
              });
            }),
            
            const SizedBox(height: PadelSpacing.md),
            
            // Third Set Toggle
            Row(
              children: [
                Checkbox(
                  value: hasThirdSet,
                  onChanged: (value) {
                    setState(() {
                      hasThirdSet = value ?? false;
                      if (!hasThirdSet) {
                        team1Set3 = null;
                        team2Set3 = null;
                      } else {
                        team1Set3 = 0;
                        team2Set3 = 0;
                      }
                    });
                  },
                  activeColor: PadelColors.primary,
                ),
                Text(
                  'Third Set Played',
                  style: PadelTypography.bodyMedium,
                ),
              ],
            ),
            
            if (hasThirdSet) ...[
              const SizedBox(height: PadelSpacing.md),
              _buildSetInput('Set 3', team1Set3 ?? 0, team2Set3 ?? 0, (t1, t2) {
                setState(() {
                  team1Set3 = t1;
                  team2Set3 = t2;
                });
              }),
            ],
            
            const SizedBox(height: PadelSpacing.lg),
            
            Row(
              children: [
                Expanded(
                  child: PadelButton(
                    text: 'Cancel',
                    onPressed: () => Navigator.pop(context),
                    style: PadelButtonStyle.outline,
                  ),
                ),
                const SizedBox(width: PadelSpacing.md),
                Expanded(
                  child: PadelButton(
                    text: 'Submit',
                    onPressed: _submitScore,
                    style: PadelButtonStyle.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetInput(String setName, int team1Score, int team2Score, Function(int, int) onChanged) {
    return Column(
      children: [
        Text(
          setName,
          style: PadelTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: PadelColors.textSecondary,
          ),
        ),
        const SizedBox(height: PadelSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              'Team 1',
              style: PadelTypography.caption.copyWith(
                color: PadelColors.textSecondary,
              ),
            ),
            Text(
              'Score',
              style: PadelTypography.caption.copyWith(
                color: PadelColors.textSecondary,
              ),
            ),
            Text(
              'Team 2',
              style: PadelTypography.caption.copyWith(
                color: PadelColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: PadelSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildScoreSelector(team1Score, (value) => onChanged(value, team2Score)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: PadelSpacing.md),
              child: Text(
                '-',
                style: PadelTypography.h5.copyWith(
                  fontWeight: FontWeight.bold,
                  color: PadelColors.textSecondary,
                ),
              ),
            ),
            _buildScoreSelector(team2Score, (value) => onChanged(team1Score, value)),
          ],
        ),
      ],
    );
  }

  Widget _buildScoreSelector(int value, Function(int) onChanged) {
    return Container(
      width: 80,
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: PadelColors.grey300),
        borderRadius: BorderRadius.circular(PadelSpacing.sm),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(value > 0 ? value - 1 : 0),
              child: Container(
                decoration: BoxDecoration(
                  color: PadelColors.grey100,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(PadelSpacing.sm),
                    bottomLeft: Radius.circular(PadelSpacing.sm),
                  ),
                ),
                child: const Icon(Icons.remove, color: PadelColors.textSecondary),
              ),
            ),
          ),
          Container(
            width: 30,
            child: Text(
              value.toString(),
              textAlign: TextAlign.center,
              style: PadelTypography.h6.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(value < 7 ? value + 1 : 7),
              child: Container(
                decoration: BoxDecoration(
                  color: PadelColors.grey100,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(PadelSpacing.sm),
                    bottomRight: Radius.circular(PadelSpacing.sm),
                  ),
                ),
                child: const Icon(Icons.add, color: PadelColors.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitScore() {
    final score = Score(
      team1Set1: team1Set1,
      team2Set1: team2Set1,
      team1Set2: team1Set2,
      team2Set2: team2Set2,
      team1Set3: team1Set3,
      team2Set3: team2Set3,
      needsOpponentConfirmation: true,
    );

    widget.onScoreSubmitted(score);
    Navigator.pop(context);

    AnalyticsService.logEvent(
      name: 'score_input_submitted',
      parameters: {
        'score': score.displayScore,
        'has_third_set': hasThirdSet,
      },
    );
  }
}