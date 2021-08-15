################################################################################
# Copyright (C) 2012-2016 Leap Motion, Inc. All rights reserved.               #
# Leap Motion proprietary and confidential. Not for distribution.              #
# Use subject to the terms of the Leap Motion SDK Agreement available at       #
# https://developer.leapmotion.com/sdk_agreement, or another agreement         #
# between Leap Motion and you, your company or other organization.             #
################################################################################

import sys, thread, time, json, math, mouse, winput

# Leap motion library path
sys.path.insert(0, "lib/leap")

import Leap
from Leap import CircleGesture, KeyTapGesture, ScreenTapGesture, SwipeGesture
from winput.vk_codes import *

import logging
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler


# Key codes gestures
swipeRightKeys = []
swipeLeftKeys = []
swipeUpKeys = []
swipeDownKeys = []
circleClockwiseKeys = []
circleAnticlockwiseKeys = []
keyTapKeys = []
screenTapKeys = []
victoryPoseKeys = []
fistPoseKeys = []

# Advanced settings
swipe_delay = 0
screen_delay = 0

circle_radius_min = 0
circle_radius_max = 0

sensitivity_x = 1
sensitivity_y = 1

hand_value = 0
mousePointerValue = 0

display_width = 0
display_height = 0

# Get index finger
indexFinger = Leap.Finger.TYPE_INDEX

# Get middle finger
middleFinger = Leap.Finger.TYPE_MIDDLE

# Setup json file

jsonFileName = "default.json"

def mapSetup(setup):

    # Mapping setup file 
    if setup['gesture'] == 'swipe right':

        swipeRightKeys.append(setup['keyCode1'])
        swipeRightKeys.append(setup['keyCode2'])
        swipeRightKeys.append(setup['keyCode3'])

    elif setup['gesture'] == 'swipe left':
        swipeLeftKeys.append(setup['keyCode1'])
        swipeLeftKeys.append(setup['keyCode2'])
        swipeLeftKeys.append(setup['keyCode3'])

    elif setup['gesture'] == 'swipe up':
        swipeUpKeys.append(setup['keyCode1'])
        swipeUpKeys.append(setup['keyCode2'])
        swipeUpKeys.append(setup['keyCode3'])

    elif setup['gesture'] == 'swipe down':
        swipeDownKeys.append(setup['keyCode1'])
        swipeDownKeys.append(setup['keyCode2'])
        swipeDownKeys.append(setup['keyCode3'])

    elif setup['gesture'] == 'circle clockwise':
        circleClockwiseKeys.append(setup['keyCode1'])
        circleClockwiseKeys.append(setup['keyCode2'])
        circleClockwiseKeys.append(setup['keyCode3'])

    elif setup['gesture'] == 'circle anticlockwise':
        circleAnticlockwiseKeys.append(setup['keyCode1'])
        circleAnticlockwiseKeys.append(setup['keyCode2'])
        circleAnticlockwiseKeys.append(setup['keyCode3'])

    elif setup['gesture'] == 'key tap':
        keyTapKeys.append(setup['keyCode1'])
        keyTapKeys.append(setup['keyCode2'])
        keyTapKeys.append(setup['keyCode3'])

    elif setup['gesture'] == 'screen tap':
        screenTapKeys.append(setup['keyCode1'])
        screenTapKeys.append(setup['keyCode2'])
        screenTapKeys.append(setup['keyCode3'])

    elif setup['gesture'] == 'fist pose':
        fistPoseKeys.append(setup['keyCode1'])
        fistPoseKeys.append(setup['keyCode2'])
        fistPoseKeys.append(setup['keyCode3'])

    elif setup['gesture'] == 'victory pose':
        victoryPoseKeys.append(setup['keyCode1'])
        victoryPoseKeys.append(setup['keyCode2'])
        victoryPoseKeys.append(setup['keyCode3'])
             
    else:
        print("Gesture unknown")


def loadJson():

    # Loading json file
    fileObject = open("setup\\" + jsonFileName, "r")
    data = fileObject.read()
    setupData = json.loads(data)
    print(json.dumps(setupData, indent=3, sort_keys=True))
    
    for setup in setupData['gestures']:
        mapSetup(setup)

    global swipe_delay
    global screen_delay
    global circle_radius_min
    global circle_radius_max
    global sensitivity_x
    global sensitivity_y
    global hand_value
    global display_width
    global display_height

    swipe_delay = setupData["swipe delay"]
    screen_delay = setupData["screen delay"]
    circle_radius_min = setupData["circle radius min"]
    circle_radius_max = setupData["circle radius max"]
    sensitivity_x = setupData["sensitivity x"]
    sensitivity_y = setupData["sensitivity y"]
    hand_value = setupData["hand"]
    display_width = setupData["display width"]
    display_height = setupData["display height"]

# check if keyCode is OEM
def checkKeyCodes(gesture):
    for i, g in enumerate(gesture):
        # +
        if g == 521:
            gesture[i] = 187 # winput.VK_OEM_PLUS
        # -
        elif g == 45: 
            gesture[i] = 189 # winput.VK_OEM_MINUS
        # ,
        elif g == 44:
            gesture[i] = 188 # winput.VK_OEM_COMMA
        # .
        elif g == 46:
            gesture[i] = 190 # winput.VK_OEM_PERIOD

def doGesture(gesture):

    checkKeyCodes(gesture)
    # Mouse press
    if gesture[0] == 1 or gesture[0] == 2 or gesture[0] == 4:   
        winput.press_mouse_button(gesture[0])
        winput.release_mouse_button(gesture[0])

    # Keyboard press 1 key
    elif gesture[0] != 0 and gesture[1] == 0 and gesture[2] == 0:

        winput.press_key(gesture[0])
        winput.release_key(gesture[0])

    # Keyboard press 2 keys
    elif gesture[0] != 0 and gesture[1] != 0 and gesture[2] == 0:
        
        winput.press_key(gesture[0])
        winput.press_key(gesture[1])
        winput.release_key(gesture[0])
        winput.release_key(gesture[1])
    
    # Keyboard press 3 keys
    elif gesture[0] != 0 and gesture[1] != 0 and gesture[2] != 0:
        
        winput.press_key(gesture[0])
        winput.press_key(gesture[1])
        winput.press_key(gesture[2])
        winput.release_key(gesture[0])
        winput.release_key(gesture[1])
        winput.release_key(gesture[2])
    
    else:
        print("Key codes are empty")
        

class SampleListener(Leap.Listener):
    finger_names = ['Thumb', 'Index', 'Middle', 'Ring', 'Pinky']
    bone_names = ['Metacarpal', 'Proximal', 'Intermediate', 'Distal']

    def on_init(self, controller):
        print("Initialized")

    def on_connect(self, controller):
        print("Connected")

        # Enable gestures
        controller.enable_gesture(Leap.Gesture.TYPE_CIRCLE)
        controller.enable_gesture(Leap.Gesture.TYPE_KEY_TAP)
        controller.enable_gesture(Leap.Gesture.TYPE_SCREEN_TAP)
        controller.enable_gesture(Leap.Gesture.TYPE_SWIPE)

    def on_disconnect(self, controller):
        # Note: not dispatched when running in a debugger.
        print ("Disconnected")

    def on_exit(self, controller):
        print ("Exited")

    def on_frame(self, controller):
        # Get the most recent frame and report some basic information
        frame = controller.frame()     

        """ print ("Frame id: %d, timestamp: %d, hands: %d, fingers: %d" % (
              frame.id, frame.timestamp, len(frame.hands), len(frame.fingers))
        )  """
        # Get hands
        for hand in frame.hands:
            

            # Check if hand is left and hand value is 1 or hand is right and hand value is 0
            if hand.is_left and hand_value == 1 or hand.is_right and hand_value == 0:

                # Get extended finger list       
                extended_finger_list = frame.fingers.extended()

                # Check if grab strength value is >=1 and if there are not extended fingers
                if hand.grab_strength >= 1 and extended_finger_list.is_empty:
                    doGesture(fistPoseKeys)
                    print "fist pose"

                finger_left_most_extended = frame.fingers.extended().leftmost
                finger_right_most_extended = frame.fingers.extended().rightmost

                # Check if victory pose has been done properly with right or left hand
                if hand.is_left:                    
                    if finger_left_most_extended.type is middleFinger and finger_right_most_extended.type is indexFinger:
                        doGesture(victoryPoseKeys)
                        print "victory pose"
                else:
                    if finger_left_most_extended.type is indexFinger and finger_right_most_extended.type is middleFinger:
                        doGesture(victoryPoseKeys)
                        print "victory pose"

                # Pointable to the frontmost object
                pointable = frame.pointables.frontmost
                
                if pointable.is_valid:
                    iBox = frame.interaction_box
                    leapPoint = pointable.stabilized_tip_position
                    normalizedPoint = iBox.normalize_point(leapPoint, False)

                    # Get x and y of normalized pointable position
                    display_x = normalizedPoint.x * display_width
                    display_y = (1 - normalizedPoint.y) * display_height
                    
                    # Move cursor 
                    mouse.move(display_x*sensitivity_x, display_y*sensitivity_y)
                
                
                """ print ("  %s, id %d, position: %s" % (
                    handType, hand.id, hand.palm_position)
                )  """
                # Get the hand's normal vector and direction
                normal = hand.palm_normal
                direction = hand.direction

                # Calculate the hand's pitch, roll, and yaw angles
                """ print ("  pitch: %f degrees, roll: %f degrees, yaw: %f degrees" % (
                    direction.pitch * Leap.RAD_TO_DEG,
                    normal.roll * Leap.RAD_TO_DEG,
                    direction.yaw * Leap.RAD_TO_DEG)
                ) """
                # Get arm bone
                arm = hand.arm
                """ print ("  Arm direction: %s, wrist position: %s, elbow position: %s" % (
                    arm.direction,
                    arm.wrist_position,
                    arm.elbow_position)
                ) """
                # Get fingers
                for finger in hand.fingers:


                    """ print ("    %s finger, id: %d, length: %fmm, width: %fmm" % (
                        self.finger_names[finger.type],
                        finger.id,
                        finger.length,
                        finger.width)
                    ) """
                    # Get bones
                    for b in range(0, 4):
                        bone = finger.bone(b)
                        """ print ("      Bone: %s, start: %s, end: %s, direction: %s" % (
                            self.bone_names[bone.type],
                            bone.prev_joint,
                            bone.next_joint,
                            bone.direction)
                        ) """
                # Get gestures
                for gesture in frame.gestures():
                    # Circle
                    if gesture.type == Leap.Gesture.TYPE_CIRCLE:
                        circle = CircleGesture(gesture)

                        if gesture.state is Leap.Gesture.STATE_STOP:
                            
                            # Check if circle radius is inside the range
                            if circle.radius >= circle_radius_min and circle.radius <= circle_radius_max:
                                # Determine clock direction using the angle between the pointable and the circle normal
                                if circle.pointable.direction.angle_to(circle.normal) <= Leap.PI/2:
                                    clockwiseness = "clockwise"
                                    # Calculate the angle swept since the last frame
                                    swept_angle = 0
                                    if circle.state != Leap.Gesture.STATE_START:
                                        previous_update = CircleGesture(controller.frame(1).gesture(circle.id))
                                        swept_angle = (circle.progress - previous_update.progress) * 2 * Leap.PI
                                        
                                        doGesture(circleClockwiseKeys)

                                else:
                                    clockwiseness = "counterclockwise"
                                    # Calculate the angle swept since the last frame
                                    swept_angle = 0
                                    if circle.state != Leap.Gesture.STATE_START:
                                        previous_update = CircleGesture(controller.frame(1).gesture(circle.id))
                                        swept_angle = (circle.progress - previous_update.progress) * 2 * Leap.PI
 
                                        doGesture(circleAnticlockwiseKeys)

                                print ("  Circle id: %d, %s, progress: %f, radius: %f, angle: %f degrees, %s" % (
                                    gesture.id, circle.state,
                                    circle.progress, circle.radius, swept_angle * Leap.RAD_TO_DEG, clockwiseness)
                                )                   
                    # Swipe
                    if gesture.type == Leap.Gesture.TYPE_SWIPE:
                                              
                        swipe = SwipeGesture(gesture)
                            
                        if gesture.state is Leap.Gesture.STATE_STOP:
                            # Swipe right
                            if swipe.direction[0] > 0 and math.fabs(swipe.direction[0]) > math.fabs(swipe.direction[1]):
                                swipe_direction = "right"                     
                                doGesture(swipeRightKeys)

                            # Swipe left
                            elif swipe.direction[0] < 0 and math.fabs(swipe.direction[0]) > math.fabs(swipe.direction[1]):
                                swipe_direction = "left"
                                doGesture(swipeLeftKeys)

                            # Swipe up
                            elif swipe.direction[1] > 0 and math.fabs(swipe.direction[0]) < math.fabs(swipe.direction[1]):
                                swipe_direction = "up"
                                doGesture(swipeUpKeys)

                            # Swipe down
                            elif swipe.direction[1] < 0 and math.fabs(swipe.direction[0]) < math.fabs(swipe.direction[1]):
                                swipe_direction = "down"
                                doGesture(swipeDownKeys)

                            print ("  Swipe direction: %s, Swipe id: %d, state: %s, position: %s, direction: %s, speed: %f, duration: %f" % (
                                swipe_direction, gesture.id, swipe.state,
                                swipe.position, swipe.direction, swipe.speed, gesture.duration_seconds)              
                            )
                            # Swipe delay
                            time.sleep(swipe_delay)
                                   
                        
                    # Key tap
                    if gesture.type == Leap.Gesture.TYPE_KEY_TAP:
                        keyTap = KeyTapGesture(gesture)
                        doGesture(keyTapKeys)

                        print ("  Key Tap id: %d, %s, position: %s, direction: %s" % (
                            gesture.id, keyTap.state,
                            keyTap.position, keyTap.direction)
                        )

                    # Screen tap
                    if gesture.type == Leap.Gesture.TYPE_SCREEN_TAP:
                        screenTap = ScreenTapGesture(gesture)
                        doGesture(screenTapKeys)

                        print("  Screen Tap id: %d, %s, position: %s, direction: %s" % (
                            gesture.id, screenTap.state,
                            screenTap.position, screenTap.direction)
                        )
                        # Screen delay
                        time.sleep(screen_delay)


class LoggingEventHandler(FileSystemEventHandler):
    """Logs all the events captured."""
    '''
    def on_moved(self, event):
        super(LoggingEventHandler, self).on_moved(event)

        what = 'directory' if event.is_directory else 'file'
        logging.info("Moved %s: from %s to %s", what, event.src_path,
                     event.dest_path)

    def on_created(self, event):
        super(LoggingEventHandler, self).on_created(event)

        what = 'directory' if event.is_directory else 'file'
        logging.info("Created %s: %s", what, event.src_path)

    def on_deleted(self, event):
        super(LoggingEventHandler, self).on_deleted(event)

        what = 'directory' if event.is_directory else 'file'
        logging.info("Deleted %s: %s", what, event.src_path)
    '''
    def on_modified(self, event):
        super(LoggingEventHandler, self).on_modified(event)
        if(event.src_path == ".\setup\default.json"):    
            loadJson()
            what = 'directory' if event.is_directory else 'file'
            logging.info("Modified %s: %s", what, event.src_path)

def main():


    # Create a sample listener and controller
    listener = SampleListener()
    controller = Leap.Controller()

    # Have the sample listener receive events from the controller
    controller.add_listener(listener)

    logging.basicConfig(level=logging.INFO,
                        format='%(asctime)s - %(message)s',
                        datefmt='%Y-%m-%d %H:%M:%S')
    
    path = sys.argv[1] if len(sys.argv) > 1 else '.'
    event_handler = LoggingEventHandler()
    observer = Observer()
    observer.schedule(event_handler, path, recursive=True)
    observer.start()

    # Keep this process running until Enter is pressed
    print ("Press Enter to quit...")
    try:
        sys.stdin.readline()
    except KeyboardInterrupt:
        observer.stop()
        pass
    finally:
        # Remove the sample listener when done
        controller.remove_listener(listener)

    
    

if __name__ == "__main__":
    loadJson()
    main()