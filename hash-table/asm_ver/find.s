.intel_syntax noprefix
.globl	_ZN9StringSet4FindEPKc

# RAX, RCX, RDX, R8, R9, R10, R11 - caller saved

_ZN9StringSet4FindEPKc:
    # Prologue
	push rbp
	mov rbp, rsp
	
	# Save string ptr
	mov r8, rsi
	
# Hash-method inlined
.FIND_HASH_SECTION:
	# Init hash value
	mov rcx, 0x811c9dc5

	# Load first byte of the string
	# and test if it's not zero 
	movsx edx, byte ptr [rsi]
	test dl, dl
	je .ROOT_NODE_CHECK
	
	# RAX - current char ptr
	mov rax, rsi

.FIND_HASH_LOOP:
	xor edx, ecx
	inc rax
	imul ecx, edx, 0x1000193
	movsx edx, byte ptr [rax]
	test dl, dl
	jne .FIND_HASH_LOOP

# Check if root node is not filled
.ROOT_NODE_CHECK:
	# [rdi] -- <<self-class obj>>
	# Load table_size_ class-field and compute `hash % table_size_`
	mov eax, ecx
	div dword ptr [rdi + 0x8]
	sal rdx, 0x5

	# Compute curr_node_ = root_nodes_ + ins_places
	mov r10, qword ptr [rdi]
	add r10, rdx
	
	# Check if filled_flag_ is zero --> root node is not filled
	movzx r9d, byte ptr [r10 + 0xC]
	test r9b, r9b

	je .FIND_NODES_LOOP_END
	jmp .STR_CHECK

.FIND_NODES_LOOP:
	# Get next_ ptr, if it's nullptr --> return false
	mov r10, qword ptr [r10 + 0x18]
	test r10, r10
	je .FIND_FALSE_RETURN

.STR_CHECK:
	# Check hashes, if not equal --> go to the next string
	cmp ecx, dword ptr [r10 + 0x8]
	jne .FIND_NODES_LOOP
	
	# Use strcmp()
	mov rdi, qword ptr [r10]
	mov rsi, r8
	call strcmp
	
	# Check equality
	test eax, eax
	jne	.FIND_NODES_LOOP

.FIND_NODES_LOOP_END:
	mov eax, r9d
	jmp .FIND_END

.FIND_FALSE_RETURN:
	xor eax, eax

.FIND_END:
	# Epilogue
	pop rbp
	ret
