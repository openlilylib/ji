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

% Functions to format the display,
% intended to make visualization configurable
#(define (format-cent cent)
   (format "(~@f)" cent))

#(define (format-ratio ratio)
   (format "(~a/~a)" (car ratio) (cdr ratio)))

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
       (list
        ;; Add cent deviation above note
        (make-music
              'TextScriptEvent
              'direction 1
              'text (format-cent cent))
        ;; Add ratio below note
         (make-music
          'TextScriptEvent
          'direction -1
          'text (format-ratio ratio)))
       'pitch
       pitch-effective
       'duration
       ji-duration)))))
