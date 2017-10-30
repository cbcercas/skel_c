# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: chbravo- <chbravo-@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/12/08 11:02:51 by chbravo-          #+#    #+#              #
#    Updated: 2017/10/30 23:15:57 by chbravo-         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

#TODO fix indent, space before '\'...
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
CFLAGS			= -g -Wall -Wextra -Werror

ifeq ($(DEV),yes)
	CFLAGS		+= -std=c11 -pedantic -pedantic-errors
endif

ifeq ($(SAN),yes)
	LDFLAGS 	+= -fsanitize=address
	CFLAGS		+= -fsanitize=address -fno-omit-frame-pointer -fno-optimize-sibling-calls
endif

ifeq ($(NOERR),yes)
    CFLAGG		= -g -Wall -Wextra -Wdeprecated-declarations
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
COUNT_OBJ		= 0
COUNT_DEP		= 0
TOTAL			= 0
PERCENT			= 0
$(eval TOTAL=$(shell echo $$(printf "%s" "$(SRCS)" | wc -w)))

#color
C_NO = \033[0m
C_G = \033[0;32m
C_Y = \033[1;33m
C_B = \033[1;34m
C_C = \033[1;36m
C_R = \033[1;31m
C_P = \033[1;35m
DOXYGEN = $(shell doxygen -v dot 2> /dev/null)

###############################################################################
#																			  #
#								DOT NOT EDIT BELOW							  #
#																			  #
###############################################################################
#########
## RULES ##
 #########
#.SECONDARY: $(OBJS) lib

.NOTPARALLEL:
all: $(DEPS) lib $(NAME)

# Add dependency as prerequisites
-include $(DEPS)


$(NAME): $(OBJS)
	@$(CC) $(CFLAGS) -o $(NAME) $(OBJS) $(LIBS) $(INC)
	@echo "$(C_G)$(C_NO) ALL LINKED $(C_G)$(C_NO)"
	@echo "INFO: Flags: $(CFLAGS)"
	@echo "[\033[35m---------------------------------\033[0m]"
	@echo "[\033[36m--------- SKELL Done ! ----------\033[0m]"
	@echo "[\033[35m---------------------------------\033[0m]"

$(OBJS_DIR)/%.o: %.c | $(OBJS_DIR)
	@$(CC) $(LDFLAGS) $(CFLAGS) $(INC) -o $@ -c $<
	$(eval COUNT_OBJ=$(shell echo $$(($(COUNT_OBJ)+1))))
	$(eval PERCENT=$(shell echo $$((($(COUNT_OBJ) * 100 )/$(TOTAL)))))
	@printf "$(C_B)%-8s $(C_P) $<$(C_NO)\n" "[$(PERCENT)%]"

$(DEPS_DIR)/%.d: %.c | $(DEPS_DIR)
	@$(CC) $(INC) -MM $< -MT $(OBJS_DIR)/$*.o -MF $@
	$(eval COUNT_DEP=$(shell echo $$(($(COUNT_DEP)+1))))
	$(eval PERCENT=$(shell echo $$((($(COUNT_DEP) * 100 )/$(TOTAL)))))
	@printf "$(C_B)%-8s $(C_G) $@$(C_NO)\n" "[$(PERCENT)%]"

$(BUILD_DIR):
	@$(MKDIR) -p $@

lib:
	#No lib

re: fclean $(DEPS) lib $(NAME)

clean:
	@echo -e "\033[35m21sh  :\033[0m [\033[31mSuppression des .o\033[0m]"
	@$(RM) $(OBJS_DIR)
	@echo -e "\033[35m21sh  :\033[0m [\033[31mSuppression des .d\033[0m]"
	@$(RM) $(DEPS_DIR)

fclean: clean
	@echo -e "\033[35m21sh  :\033[0m [\033[31mSuppression de $(NAME)\033[0m]"
	@$(RM) $(NAME)
	@rm -rf DOC

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
