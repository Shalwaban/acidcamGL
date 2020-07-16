
#include"gl_window.hpp"

namespace acidcam {
    
    int glWindow::create(bool record, bool full, std::string name, int w, int h) {
#ifdef __APPLE__
        glfwWindowHint (GLFW_CONTEXT_VERSION_MAJOR, 4);
        glfwWindowHint (GLFW_CONTEXT_VERSION_MINOR, 1);
        glfwWindowHint (GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
        glfwWindowHint (GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
#endif
        if(record)
            glfwWindowHint(GLFW_RESIZABLE, GLFW_TRUE);
        window = glfwCreateWindow(w, h, name.c_str(),(full == true && record == false) ? glfwGetPrimaryMonitor() : 0,0);
        if(!window) return 0;
        glfwMakeContextCurrent(window);
        if(glewInit()!=GLEW_OK)
            exit(EXIT_FAILURE);
        
        window_width = w;
        window_height = h;
        if(record) {
            glfwGetWindowSize(window, &w, &h);
            glfwSetWindowSizeLimits(window, w, h, w, h);
        }
        glfwSwapInterval(1);
        init();
        return 1;
    }
    
    void glWindow::loop() {
        active = true;
        while(!glfwWindowShouldClose(window) && active == true) {
            update(glfwGetTime());
            glfwSwapBuffers(window);
            glfwPollEvents();
        }
        glfwDestroyWindow(window);
    }
    
    bool checkForError() {
        bool e = false;
        int glErr = glGetError();
        while(glErr != GL_NO_ERROR) {
            std::cout << "GL Error: " << glErr << "\n";
            std::cout << "Error String: " << glewGetErrorString(glErr) << "\n";
            e = true;
            glErr = glGetError();
        }
        return e;
    }
}
