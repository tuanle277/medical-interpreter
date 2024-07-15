import cv2
import threading
from gemini import GeminiClient

class Camera:
    def __init__(self):
        self.cap = cv2.VideoCapture(0)
        self.gemini_client = GeminiClient()

    def start_capture(self, context_update_callback):
        def capture_video():
            while True:
                ret, frame = self.cap.read()
                if not ret:
                    break
                image_path = "current_frame.jpg"
                cv2.imwrite(image_path, frame)
                response = self.gemini_client.get_understanding(image_path)
                emotions = response.get('emotions', [])
                understanding = self.gemini_client.get_understanding(image_path)
                context_update_callback(emotions, understanding)
                if cv2.waitKey(1) & 0xFF == ord('q'):
                    break
            self.cap.release()

        threading.Thread(target=capture_video).start()
