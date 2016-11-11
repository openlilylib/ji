%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                             %
% This file is part of openLilyLib,                                           %
%                      ===========                                            %
% the community library project for GNU LilyPond                              %
% (https://github.com/openlilylib)                                            %
%                                                                             %
% Library: ji                                                                 %
%          ==                                                                 %
%                                                                             %
% openLilyLib is free software: you can redistribute it and/or modify         %
% it under the terms of the GNU General Public License as published by        %
% the Free Software Foundation, either version 3 of the License, or           %
% (at your option) any later version.                                         %
%                                                                             %
% openLilyLib is distributed in the hope that it will be useful,              %
% but WITHOUT ANY WARRANTY; without even the implied warranty of              %
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the               %
% GNU General Public License for more details.                                %
%                                                                             %
% You should have received a copy of the GNU General Public License           %
% along with openLilyLib. If not, see <http://www.gnu.org/licenses/>.         %
%                                                                             %
% openLilyLib is maintained by Urs Liska, ul@openlilylib.org                  %
% and others.                                                                 %
%       Copyright Urs Liska, 2016                                             %
%                                                                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\version "2.19.50"


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Configuration

% Maintain the fundamental, initialize to a default middle c
#(define ji-fundamental (ly:make-pitch 0 0 0))

% Change the fundamental, active for following notes
jiFundamental =
#(define-void-function (fund) (ly:pitch?)
   (set! ji-fundamental fund))

% Maintain a current duration to be used when no duration is given,
% initialize to quarter notes (like with regular pitches without duration)
#(define ji-duration (ly:make-duration 2))


% Map the semitone returned by ratio->step-deviation
% to a LilyPond pitch definition.
% This is based on the middle c and has to be transposed later
#(define (semitones->pitch semitone)
   (let
     ;; two lists defining the 12 steps within the octave
     ;;       c  cis  d  dis  e  f  fis  g  as   a  bes   b
    ((steps '(0  0    1  1    2  3  3    4  4    5  6     6))
     (semis '(0  1/2  0  1/2  0  0  1/2  0  1/2  0  -1/2  0))
     ;; strip semitons of octave
     (index (modulo semitone 12)))
     (ly:make-pitch
      (floor (/ semitone 12))
      (list-ref steps index)
      (list-ref semis index))))

% Local predicate which is necessary to process two optional arguments
#(define (pitch-or-dur? obj)
   (or (ly:pitch? obj)
       (ly:duration? obj)))

% Produce a note in Just Intonation.
% If fund(amental) is given change the fundamental to calculate pitches from
% if dur(ation) is given change the duration.
jiNote =
#(define-music-function (fund dur ratio)
   ((pitch-or-dur?) (ly:duration?) fraction?)
   (if fund
       ;; at least one optional argument has been given
       (if (ly:pitch? fund)
           ;; set new fundamental pitch
           (set! ji-fundamental fund)
           ;; "first" (i.e. only) optional argument is a duration:
           ;; set the new duration
           (set! ji-duration fund)))
   (if dur
       ;; second optional argument is present: set duration
       (set! ji-duration dur))

   (let*
     ;; note as pair of semitone-interval and cent deviation
    ((ji-note (ratio->step-deviation (/ (car ratio) (cdr ratio))))
     ;; LilyPond pitch as defined by the ratio
     (pitch-ratio (semitones->pitch (car ji-note)))
     ;; LilyPond pitch relative to the current fundamental
     (pitch-effective
      (ly:pitch-transpose
       pitch-ratio
       ji-fundamental))
     ;; cent deviation as integer
     (cent (cdr ji-note)))
    ;; finally create the note with generated pitch and markup addition
    (make-music
     'SequentialMusic
     'elements
     (list
      (make-music
       'NoteEvent
       'articulations
       (list (make-music
              'TextScriptEvent
              'direction 1
              'text (format "(~@f)" cent))
         (make-music
          'TextScriptEvent
          'direction -1
          'text (format "~a" ratio)))
       'pitch
       pitch-effective
       'duration
       ji-duration)))))
