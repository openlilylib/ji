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

\version "2.19.51"

% Function to enable cross staff stems with varying noteheads.
% (Cross staff only works when the horizontal position of the stems is
%  close enough, which is broken by alternative note heads. The function
%  pushes the note column of the to-be-combined note to a position where
%  the condition is met.)
%
% Provided by Thomas Morley:
% http://lists.gnu.org/archive/html/lilypond-user/2016-11/msg00555.html
%
pushNC =
\override NoteColumn.X-offset =
#(lambda (grob)
   (let* ((p-c (ly:grob-parent grob X))
          (p-c-elts (ly:grob-object p-c 'elements))
          (stems
           (if (ly:grob-array? p-c-elts)
               (filter
                (lambda (elt)(grob::has-interface elt 'stem-interface))
                (ly:grob-array->list p-c-elts))
               #f))
          (stems-x-exts
           (if stems
               (map
                (lambda (stem)
                  (ly:grob-extent
                   stem
                   (ly:grob-common-refpoint grob stem X)
                   X))
                stems)
               '()))
          (sane-ext
           (filter interval-sane? stems-x-exts))
          (cars (map car sane-ext)))
     (if (pair? cars)
         (abs (- (apply max cars)  (apply min cars)))
         0)))


% Functions to format the textual elements of the display,
% intended to make visualization configurable
%
% TODO: Make configurable and nicer in general
#(define (format-cent cent)
   (format "(~@f)" cent))

#(define (format-ratio ratio)
   (format "(~a/~a)" (car ratio) (cdr ratio)))


% Produce the text elements specifying the JI note
% Returns a list of TextScriptEvent music expressions
% that can be attached to the JI note chord.
%
% Generation of
% - ratio
% - cent
% is controlled by options
%
% TODO:
% Make styling and directions configurable
#(define (ji-legend ratio cent)
   (let
    ((artics
      (list
       ;; Add ratio below note
       (if (getOption '(ji show ratio))
           (make-music
            'TextScriptEvent
            'direction 1
            'tweaks
            (list
             '(font-size . -3.5)
             '(self-alignment-X . -0.25))
            'text (format-ratio ratio))
           #f)
       ;; Add cent deviation above note
       (if (getOption '(ji show cent))
           (make-music
            'TextScriptEvent
            'direction 1
            'tweaks
            (list
             '(font-size . -3.5)
             '(self-alignment-X . -0.25))
            'text (format-cent cent))
           #f)
       )))
    ;; remove empty expressions
    (delq #f artics)))

#(define (cent-color cent)
   (list 1 0 0)
     )

% Produce a color based on the cent detune.
% Positive detunes color increasingly red
% while negative colors produce shades of blue
#(define (cent->color cent)
   (let
    ((r (if (> cent 0)
            (sqrt (/ cent 50.0))
            0.0))
     (b (if (< cent 0)
            (sqrt (* -1 (/ cent 50.0)))
            0.0)))
    (list r 0.0 b)))


% Generate set of tweaks applying to the JI note
% Controlled by options
#(define (ji-tweaks ratio cent)
   (let
    ((tweaks
      (list
       ;; define notehead style
       (cons (cons 'NoteHead 'style)
         (getOption '(ji show notehead-style)))
       (if (getOption '(ji conf use-color))
           (let 
            ((col (cent->color cent)))
            (cons (cons 'NoteHead 'color) col))
           #f)
       ;; If we're on the upper part of a cross staff chord
       ;; stem should always point upwards
       ;
       ; TODO
       ; ideally this should check for the stem direction of the outer voice.
       ; if \oneVoice is active the proper stem direction for the whole
       ; cross staff chord should be determined and applied to both parts
       ;
       (if (getOption '(ji conf use-cross-staff))
           (cons (cons 'Stem 'direction) 1)
           #f)
       )))
    ;; remove empty expressions
    (delq #f tweaks)))

% Produce a NoteEvent with given pitch and duration,
% to be used in the composition of chords or single notes.
% tweaks is either a list of tweaks or an empty list
#(define (ji-produce-note pitch duration tweaks)
   (make-music
    'NoteEvent
    'tweaks tweaks
    'pitch pitch
    'duration duration))

% Return a JI NoteEvent with styling
#(define (ji-note pitch dur ratio cent)
   (ji-produce-note pitch dur (ji-tweaks ratio cent)))

% Return a simple NoteEvent
#(define (ji-simple-note pitch dur)
   (ji-produce-note pitch dur '()))

% Produce a note in Just Intonation.
% Returns either a chord (with one or two notes) or
% a temporary polyphony construct with two voices,
% distributed over two staves. This is controlled by the
% ji.conf.use-cross-staff option (default: ##f)
% In this case the name of the secondary staff is controlled by the
% ji.conf.cross-staff.upper-name option (default: "ji-upper"),
% and it's the user's responsibility to provide an active context of that name.
% Note that the fundamental pitch will continue the Voice context while the
% resulting pitch is printed in a temporary Voice.
%
% If fund(amental) is given changes the fundamental to calculate pitches from
% if dur(ation) is given changes the duration.
% Both changes apply for later JI events as well
%
% Most of the behaviour and appearance is controlled by options.

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
    ((ji-event (ratio->step-deviation (/ (car ratio) (cdr ratio))))
     ;; LilyPond pitch as defined by the ratio
     (pitch-ratio (semitones->pitch (car ji-event)))
     ;; LilyPond pitch relative to the current fundamental
     (pitch-effective
      (ly:pitch-transpose
       pitch-ratio
       ji-fundamental))
     ;; cent deviation as integer
     (cent (cdr ji-event)))

    (if (getOption '(ji conf use-cross-staff))
        ;; Produce a temporary cross-staff section for a single note
        #{
          <<
            \crossStaff {
              #(if (getOption '(ji show fundamental))
                   ;; If active print the fundamental in the original staff.
                   ;; Produce a chord in order to be able to
                   ;; display the legend.
                   (make-music
                    'EventChord
                    'elements
                    (let*
                     ((legend
                       (if (not (getOption '(ji show notehead)))
                           ;; only show the legend with the fundamental
                           ;; when the resulting pitch isn't printed
                           (ji-legend ratio cent)
                           (list #f)))
                      (elts
                       `(
                          ;; fundamental pitch
                          ,(ji-simple-note ji-fundamental ji-duration)
                          ;; legend or empty list
                          ,@legend)))
                     (delq #f elts)))
                   #{ #})
            }
            #(if (getOption '(ji show notehead))
                 ;; Create a temporary voice for the resulting pitch
                 #{
                   \new Voice {
                     % Print resulting pitch on "upper" staff
                     \change Staff = #(getOption '(ji conf cross-stuff upper-name))
                     % Adjust horizontal position (for differing notehead styles
                     % to enable cross staff
                     \once \pushNC
                     % Produce "chord" with pitch and legend
                     #(make-music
                       'EventChord
                       'elements
                       (let
                        ((elts
                          `(
                             ,(ji-note pitch-effective ji-duration ratio cent)
                             ,@(ji-legend ratio cent)
                             )))
                        (delq #f elts)))
                   }
                 #})
          >>
        #}
        ;; Cross staff is not selected:
        ;; Produce a single-staff chord
        (make-music
         'EventChord
         'elements
         (let
          ((elts
            `(
               ;; Optionally display fundamental and resulting pitch
               ,(if (getOption '(ji show fundamental))
                    (ji-simple-note ji-fundamental ji-duration)
                    #f)
               ,(if (getOption '(ji show notehead))
                    (ji-note pitch-effective ji-duration ratio cent)
                    #f)
               ,@(ji-legend ratio cent)
               )))
          (delq #f elts)))
        )))
