# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: chbravo- <chbravo-@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/12/08 11:02:51 by chbravo-          #+#    #+#              #
#    Updated: 2017/12/19 22:46:19 by chbravo-         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

NAME			= skell

SRC_SUBDIR		= core
SRCS			+= main.c

###############################################################################
#																			  #
#									CONFIG									  #
#																			  #
###############################################################################
#  Compiler
CC				= clang
CFLAGS			= -Wall -Wextra

ifneq ($(NOERR),yes)
    CFLAGS		+= -Werror
endif

ifeq ($(DEV),yes)
    CFLAGS		+= -g
endif

ifeq ($(SAN),yes)
    CFLAGS		+= -fsanitize=address -fno-omit-frame-pointer -fno-optimize-sibling-calls
endif

#The Directories, Source, Includes, Objects and Libraries
INC				= -I includes
SRCS_DIR		= srcs
vpath  %c $(addprefix $(SRCS_DIR)/,$(SRC_SUBDIR))

#Objects
OBJS_DIR		= objs
OBJS			= $(SRCS:%.c=$(OBJS_DIR)/%.o)

# Dependencies
DEPS_DIR		= .deps
DEPS			= $(SRCS:%.c=$(DEPS_DIR)/%.d)
BUILD_DIR		= $(OBJS_DIR) $(DEPS_DIR)


#Utils
RM				= rm -rf
MKDIR			= mkdir -p

DOXYGEN = $(shell doxygen -v dot 2> /dev/null)

###############################################################################
#																			  #
#								DOT NOT EDIT BELOW							  #
#																			  #
###############################################################################
#########
## RULES ##
 #########
all: $(DEPS_DIR) lib $(NAME)

# Add dependency as prerequisites
ifneq ($(MAKECMDGOALS),clean)
 ifneq ($(MAKECMDGOALS),fclean)
  ifneq ($(MAKECMDGOALS),doc)
   -include $(DEPS)
  endif
 endif
endif

$(NAME): $(OBJS)
	$(CC) $(CFLAGS) -o $(NAME) $(OBJS) $(LIBS) $(INC)
	@echo "INFO: Flags: $(CFLAGS)"
	@echo "Done"

$(OBJS_DIR)/%.o: %.c Makefile | $(OBJS_DIR)
	$(CC) $(LDFLAGS) $(CFLAGS) $(INC) -o $@ -c $<

.PRECIOUS: $(DEPS_DIR)/%.d
$(DEPS_DIR)/%.d: %.c | $(DEPS_DIR)
		@$(CC) $(INC) -MM $< -MT $(OBJS_DIR)/$*.o -MF $@

$(BUILD_DIR):
	@$(MKDIR) -p $@

lib:
	#No lib

re: fclean $(DEPS) lib $(NAME)

clean:
ifeq ($(shell [ -e $(OBJS_DIR) ] && echo 1 || echo 0),1)
	$(RM) $(OBJS_DIR)
endif
ifeq ($(shell [ -e $(DEPS_DIR) ] && echo 1 || echo 0),1)
	$(RM) $(DEPS_DIR)
endif

fclean: clean
ifeq ($(shell [ -e $(NAME) ] && echo 1 || echo 0),1)
	$(RM) $(NAME)
endif

dev:
	@make -C ./ SAN="yes" DEV="yes"

doc:
ifndef DOXYGEN
	@echo $(DOXYGEN)
	@echo "Please install doxygen and graphviz first (brew install doxygen graphviz)."
else
	@doxygen Doxyfile
	@echo "[\033[35m--------------------------\033[0m]"
	@echo "[\033[36m------ Documentation -----\033[0m]"
	@echo "[\033[36m------   generated   -----\033[0m]"
	@echo "[\033[35m--------------------------\033[0m]"
endif

.PHONY: re clean fclean all lib doc dev
.SUFFIXES: .c .h .o .d
